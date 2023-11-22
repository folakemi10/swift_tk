//
//  Algorithms.swift
//  Image-modification-toolkit
//
//  Created by Luke Zhang on 11/15/23.
//

import Foundation

import SwiftImage
import UIKit

class ImageModificationClass{
    
    //initialize images as all black, process them from file uploads later
    var image:Image = Image<RGBA<UInt8>>(width: 1000, height: 1000, pixel: .black)
    var rawImage:Image = Image<RGBA<UInt8>>(width: 1000, height: 1000, pixel: .black)
    
    private var tempRoots: [Int] = []
    private var pixelSize: Int = 0
    private var tempA: [Int] = []
    private var safePrime: Int = 0
    private var secretCode: String = ""
    
    public func getSafePrime() -> Int {
        return safePrime
    }
    public func tempRootArray() -> [Int]{
        return tempRoots
    }
    public func enhancedTempRootArray() -> [Int]{
        return tempRoots + tempA
    }
    public func getSecretCode () -> String {
        return secretCode
    }
    private var safePrimes: [Int] = [5, 7, 11, 23, 47, 59, 83, 107, 167, 179, 227, 263, 347, 359, 383, 467, 479, 503, 563, 587, 719, 839, 863, 887, 983, 1019, 1187, 1283, 1307, 1319, 1367, 1439, 1487, 1523, 1619, 1823, 1907, 2027, 2039, 2063, 2099, 2207, 2447, 2459, 2579, 2819, 2879, 2903, 2963, 2999, 3023, 3119, 3167, 3203, 3467, 3623, 3779, 3803, 3863, 3947, 4007, 4079, 4127, 4139, 4259, 4283, 4547, 4679, 4703, 4787, 4799, 4919]
    
    public func setSafePrimeIndex (spIndex: Int) {
        safePrime = safePrimes[spIndex]
    }
    public func setMosaicPixelSize (pxSize: Int) {
        pixelSize = pxSize
    }
    
    private var approxImages: [Image<RGBA<UInt8>>] = []
    
    public func setApproxImages (directoryName: String, size: Int) throws {
        for file in try Folder(path: directoryName).files {
            guard let image = Image<RGBA<UInt8>>(named: file.name)
            else {return}
            let newImage = image.resizedTo(width:size, height: size)
            approxImages.append(newImage)
        }
    }
    
    // SPECIAL METHOD: process raw image from UIImage
    public func processRawImageFromUIImg (img: UIImage) {
        rawImage = Image<RGBA<UInt8>>(uiImage: img)
    }
       
    public func getApproxImages() -> [Image<RGBA<UInt8>>] {
        return approxImages
    }
   
    private func computeAverage (image:Image<RGBA<UInt8>>) -> RGBA<UInt8> {
        var rSum: Int = 0, gSum: Int = 0, bSum: Int = 0
        for i in image.xRange {
            for j in image.yRange {
                let pixel: RGBA<UInt8> = image[i, j]
                rSum += Int(pixel.red)
                gSum += Int(pixel.green)
                bSum += Int(pixel.blue)
            }
        }
        let totalPixels = image.width * image.height
        let rAvg = UInt8(rSum / totalPixels)
        let gAvg = UInt8(gSum / totalPixels)
        let bAvg = UInt8(bSum / totalPixels)
        return RGBA(red: rAvg, green: gAvg, blue: bAvg)
    }
    private func computeAverages (input:[Image<RGBA<UInt8>>]) -> [RGBA<UInt8>] {
        var result: [RGBA<UInt8>] = []
        for i in input {
            result.append(computeAverage(image:i))
        }
        return result
    }
    private func determineClosestIndex (input: RGBA<UInt8>) -> Int {
        var minDistance:Double = 99999999
        var minDistanceIndex:Int = 0
        let colorBank:[RGBA<UInt8>] = computeAverages(input: approxImages)
        let red:Double = Double(input.red)
        let green:Double = Double(input.green)
        let blue:Double = Double(input.blue)
        for i in 0..<colorBank.count{
            let candidate = colorBank[i]
            let candidateRed:Double = Double(candidate.red)
            let candidateGreen:Double = Double(candidate.green)
            let candidateBlue:Double = Double(candidate.blue)
            let squared:Double = pow(candidateRed - red, 2)
                               + pow(candidateGreen - green, 2)
                               + pow(candidateBlue - blue, 2)
            let distance:Double = sqrt(squared)
            if distance < minDistance {
                minDistance = distance
                minDistanceIndex = i
            }
        }
        return minDistanceIndex
    }
    public func emojify (width: Int, height: Int, emojiSize: Int) throws {
        image = rawImage.resizedTo(width: width, height: height)
        for x in 0 ..< width {
            for y in 0 ..< height {
                let slice: ImageSlice<RGBA<UInt8>> = image[x * emojiSize ..< x * emojiSize + emojiSize, y * emojiSize ..< y * emojiSize + emojiSize]
                let sub:Image<RGBA<UInt8>> = Image<RGBA<UInt8>>(slice)
                let inputColor:RGBA<UInt8> = computeAverage(image: sub)
                let index:Int = determineClosestIndex(input: inputColor)
                let replace:Image<RGBA<UInt8>> = approxImages[index]
                for i in x * emojiSize ..< (x+1) * emojiSize {
                    for j in y * emojiSize ..< (y+1) * emojiSize {
                        let newRGB:RGBA<UInt8> = replace[i % emojiSize, j % emojiSize]
                        image[i, j] = newRGB
                    }
                }
            }
        }
//        let imageView: UIImageView = UIImageView(image: image.uiImage)
        UIImageWriteToSavedPhotosAlbum(image.uiImage, nil, nil, nil)
    }
    
    //constructor
    init(directory: String) {
        rawImage = Image<RGBA<UInt8>>.init(contentsOfFile: directory) ?? Image<RGBA<UInt8>>(width: 1, height: 1, pixel: .black)
    }
    
    //another constructor
    init (imageArg: UIImage) {
        processRawImageFromUIImg (img: imageArg)
    }
    
    public func getCurrentImage () -> Image<RGBA<UInt8>> {
        return image
    }
    
    //now let's start building the methods from bottom up (hierarchy-wise)
    
    //these are the deepest layer (layer 1), most primitive, helper functions
    private func prToThe(base: Int, k: Int) -> Int {
        var value = 1
        for i in 0..<k {
            value *= base
            value %= safePrime
        }
        return value
    }


    
    private func discreteLogarithm(_ a: Int, _ b: Int, _ m: Int) -> Int {
        let n = Int(Double(m).squareRoot()) + 1
        var an = 1
        for i in 0..<n {
            an = (an * a) % m
        }
        var value = [Int](repeating: 0, count: m)
        
        var cur = an
        for i in 1...n {
            if (value[cur] == 0) {
                value[cur] = i
            }
            cur = (cur * an) % m
        }
        
        cur = b
        for i in 0...n {
            if (value[cur] > 0) {
                var ans = value[cur] * n - i
                if (ans < m) {
                    return ans
                }
            }
            cur = (cur * a) % m
        }
        return -1
    }
    
    private func discreteLogBasePrModsafePrime_ (base: Int, k: Int) -> Int {
        return discreteLogarithm(base, k, safePrime);
    }
    
    private func computeNthRootModSafePrime (n: Int, origNum: Int) -> Int {
        var result: Int = -1
        for i in 0..<safePrime {
            if (prToThe(base: i, k: n) == origNum) {
                result = i
                break
            }
        }
        return result
    }
    
    private func resizeImage (orig: Image<RGBA<UInt8>>, targetWidth: Int, targetHeight: Int) -> Image<RGBA<UInt8>> {
        return orig.resizedTo(width: targetWidth, height: targetHeight)
    }
    
    //next layer (layer 2) of helper functions
    
    private func mosaicEncrypt (original: [Image<RGBA<UInt8>>], pr: Int) -> [Image<RGBA<UInt8>>] {
        var newArr: [Image<RGBA<UInt8>>] = []
        for i in 0..<original.count {
            newArr.append(original[prToThe(base: pr, k: i) - 1])
        }
        return newArr
    }
    
    private func funnyMosaicEncrypt (original: [Image<RGBA<UInt8>>], a: Int) -> [Image<RGBA<UInt8>>] {
        var newArr: [Image<RGBA<UInt8>>] = []
        for i in 0..<original.count {
            newArr.append(original[prToThe(base: i+1, k: a) - 1])
        }
        return newArr
    }
    
    private func mosaicDecrypt (original: [Image<RGBA<UInt8>>], pr: Int) -> [Image<RGBA<UInt8>>] {
        var newArr: [Image<RGBA<UInt8>>] = []
        for i in 0..<original.count {
            newArr.append(original[discreteLogBasePrModsafePrime_(base: pr, k: i+1) % (safePrime - 1)])
        }
        return newArr
    }
    
    private func funnyMosaicDecrypt (original: [Image<RGBA<UInt8>>], a: Int) -> [Image<RGBA<UInt8>>] {
        var newArr: [Image<RGBA<UInt8>>] = []
        for i in 0..<original.count {
            newArr.append(original[computeNthRootModSafePrime(n: a, origNum: i+1) - 1])
        }
        newArr.append(original[safePrime - 2])
        return newArr
    }
    
    //next layer (layer 3) of helper functions
    
    private func mosaicScramble(original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        var m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origRow.append(m.getPixel(xCoord:j, yCoord: y))
            }
            var scrambledRow = mosaicEncrypt(original: origRow, pr: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: j, y: y, inputimg: scrambledRow[j])
            }
        }
        scrambled = m.getMosaic()
        return scrambled
    }
    /*
     private static BufferedImage mosaicScramble (BufferedImage original, int pr) throws IOException {
        BufferedImage scrambled = original;
        Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, scrambled);
        for (int y = 0; y < safePrime - 1; y++) {
             ArrayList<BufferedImage> origRow = new ArrayList<BufferedImage>();
            
            for (int j = 0; j < safePrime - 1; j++) {
                BufferedImage c = m.getPixel(j, y);
                origRow.add(c);
            }

            ArrayList<BufferedImage> scrambledRow = mosaicEncrypt (origRow, pr);
    
          
            for (int j = 0; j < safePrime - 1; j++) {
                BufferedImage newImage = scrambledRow.get(j);
                m.setPixel(j, y, newImage);
                
            }

        }
        scrambled = m.getMosaic();
        return scrambled;
        
    }
     */
    
    private func mosaicScramble2 (original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        var m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origCol.append(m.getPixel(xCoord:x, yCoord: j))
            }
            var scrambledCol = mosaicEncrypt(original: origCol, pr: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: x, y: j, inputimg: scrambledCol[j])
            }
        }
        scrambled = m.getMosaic()
        return scrambled
    }
    /*
     private static BufferedImage mosaicScramble2 (BufferedImage original, int pr) throws IOException {
       BufferedImage scrambled = original;
      
       Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, scrambled);
       //scramble each column
       for (int x = 0; x < safePrime - 1; x++) {
           ArrayList<BufferedImage> origCol = new ArrayList<BufferedImage>();
           for (int j = 0; j < safePrime - 1; j++) {
               BufferedImage c = m.getPixel(x, j);
               origCol.add(c);
           }
          
           ArrayList<BufferedImage> scrambledCol = mosaicEncrypt2 (origCol, pr);
           for (int j = 0; j < safePrime - 1; j++) {
               BufferedImage newImage = scrambledCol.get(j);
               m.setPixel(x, j, newImage);
           }
         


       }
       scrambled = m.getMosaic();
       return scrambled;
     }
     */
    
    
    private func mosaicScrambleD1(original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        var m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                var modifiedY = (y + prToThe(base: pr1, k: j)) % (safePrime - 1)
                origRow.append(m.getPixel(xCoord:j, yCoord: modifiedY))
            }
            var scrambledRow = mosaicEncrypt(original: origRow, pr: pr2)
            for j in 0..<(safePrime-1) {
                var modifiedY = (y + prToThe(base: pr1, k: j)) % (safePrime - 1)
                m.setPixel(x: j, y: modifiedY, inputimg: scrambledRow[j])
            }
        }
        scrambled = m.getMosaic()
        return scrambled
    }
    /*
     private static BufferedImage mosaicScrambleD1 (BufferedImage original, int pr1, int pr2) throws IOException {
          BufferedImage scrambled = original;
         
       Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, scrambled);

          //scramble each row
          for (int y = 0; y < safePrime - 1; y++) {
              ArrayList<BufferedImage> origRow = new ArrayList<BufferedImage>();
              for (int j = 0; j < safePrime - 1; j++) {
                  int modifiedY = (y + (prToThe(pr1, j))) % (safePrime - 1);
                  BufferedImage c = m.getPixel(j, modifiedY);
                  origRow.add(c);
              }
             
              ArrayList<BufferedImage> scrambledRow = mosaicEncrypt (origRow, pr2);
              for (int j = 0; j < safePrime - 1; j++) {
                  int modifiedY = (y + (prToThe(pr1, j))) % (safePrime - 1);
                  BufferedImage newImage = scrambledRow.get(j);
                  
                  m.setPixel(j, modifiedY, newImage);
                  
              }
             


          }
       scrambled = m.getMosaic();
          return scrambled;
      }
   
     */
    
    private func mosaicScrambleD2(original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        var m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                var modifiedX = (x + prToThe(base: pr1, k: j)) % (safePrime - 1)
                origCol.append(m.getPixel(xCoord:modifiedX, yCoord: j))
            }
            var scrambledCol = mosaicEncrypt(original: origCol, pr: pr2)
            for j in 0..<(safePrime-1) {
                var modifiedX = (x + prToThe(base: pr1, k: j)) % (safePrime - 1)
                m.setPixel(x: modifiedX, y: j, inputimg: scrambledCol[j])
            }
        }
        scrambled = m.getMosaic()
        return scrambled
    }
    
    /*
     private static BufferedImage mosaicScrambleD2 (BufferedImage original, int pr1, int pr2) throws IOException{
           BufferedImage scrambled = original;
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, scrambled);
           
           //scramble each column
           for (int x = 0; x < safePrime - 1; x++) {
               ArrayList<BufferedImage> origCol = new ArrayList<BufferedImage>();
               for (int j = 0; j < safePrime - 1; j++) {
                   int modifiedX = (x + (prToThe(pr1, j))) % (safePrime - 1);
                   BufferedImage c = m.getPixel(modifiedX, j);
                   origCol.add(c);
               }
              
               ArrayList<BufferedImage> scrambledCol = mosaicEncrypt2 (origCol, pr2);
               for (int j = 0; j < safePrime - 1; j++) {
                   int modifiedX = (x + (prToThe(pr1, j))) % (safePrime - 1);
                   BufferedImage newImage = scrambledCol.get(j);
                   m.setPixel(modifiedX, j, newImage);
               }
             


           }
           scrambled = m.getMosaic();
           return scrambled;
      }
     */
    
    private func mosaicUnscrambleRows (original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        var m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origCol.append(m.getPixel(xCoord:x, yCoord: j))
            }
            var unscrambledCol = mosaicDecrypt(original: origCol, pr: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: x, y: j, inputimg: unscrambledCol[j])
            }
        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    /*
     public static BufferedImage mosaicUnscrambleRows (BufferedImage original, int pr) throws IOException {
           BufferedImage unscrambled = original;
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, unscrambled);

           //scramble each column
           for (int x = 0; x < safePrime - 1; x++) {
               ArrayList<BufferedImage> origCol = new ArrayList <BufferedImage> ();
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage c = m.getPixel(x, j);
                   origCol.add(c);
               }
              
               ArrayList<BufferedImage> unscrambledCol = mosaicDecryptCols (origCol, pr);
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage newImage = unscrambledCol.get(j);
                   m.setPixel(x, j, newImage);
               }
               System.out.println("Row " + x + " unscrambled");
     
     }
           unscrambled = m.getMosaic();
           return unscrambled;
         }

     */
    
    private func mosaicUnscrambleCols (original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        var m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origRow.append(m.getPixel(xCoord:j, yCoord: y))
            }
            var unscrambledRow = mosaicDecrypt(original: origRow, pr: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: j, y: y, inputimg: unscrambledRow[j])
            }
        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    /*
         public static BufferedImage mosaicUnscrambleCols (BufferedImage original, int pr) throws IOException {
               BufferedImage unscrambled = original;
               Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, unscrambled);
              
               //scramble each row
               for (int y = 0; y < safePrime - 1; y++) {
                   ArrayList<BufferedImage> origRow = new ArrayList <BufferedImage> ();
                   for (int j = 0; j < safePrime - 1; j++) {
                       BufferedImage c = m.getPixel(j, y);
                       origRow.add(c);
                   }
                  
                   ArrayList<BufferedImage> unscrambledRow = mosaicDecryptRows (origRow, pr);
                   for (int j = 0; j < safePrime - 1; j++) {
                       BufferedImage newImage = unscrambledRow.get(j);
                       m.setPixel(j, y, newImage);
                   }
                   System.out.println("Column " + y + " unscrambled");
                   



               }
               unscrambled = m.getMosaic();
               return unscrambled;
           }
     */
    
    private func mosaicUnscrambleD1 (original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        var m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                var modifiedY = (y + prToThe(base: pr1, k: j)) % (safePrime - 1)
                origRow.append(m.getPixel(xCoord:j, yCoord: modifiedY))
            }
            var unscrambledRow = mosaicDecrypt(original: origRow, pr: pr2)
            for j in 0..<(safePrime-1) {
                var modifiedY = (y + prToThe(base: pr1, k: j)) % (safePrime - 1)
                m.setPixel(x: j, y: modifiedY, inputimg: unscrambledRow[j])
            }
        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    /*
     public static BufferedImage mosaicUnscrambleD1 (BufferedImage original, int pr1, int pr2) throws IOException {
            BufferedImage unscrambled = original;
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, unscrambled);

            //scramble each row
            for (int y = 0; y < safePrime - 1; y++) {
                ArrayList<BufferedImage> origRow = new ArrayList <BufferedImage> ();
                for (int j = 0; j < safePrime - 1; j++) {
                       int modifiedY = (y + (prToThe(pr1, j))) % (safePrime - 1);
                    BufferedImage c = m.getPixel(j, modifiedY);
                    origRow.add(c);
                }
               
                ArrayList<BufferedImage> unscrambledRow = mosaicDecryptRows (origRow, pr2);
                for (int j = 0; j < safePrime - 1; j++) {
                       int modifiedY = (y + (prToThe(pr1, j))) % (safePrime - 1);
                    BufferedImage newImage = unscrambledRow.get(j);
                    m.setPixel(j, modifiedY, newImage);
                }
                System.out.println("Column " + y + " unscrambled");
                    


            }
            unscrambled = m.getMosaic();
            return unscrambled;
        }
     
     */
    
    private func mosaicUnscrambleD2 (original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        var m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                var modifiedX = (x + prToThe(base: pr1, k: j)) % (safePrime - 1)
                origCol.append(m.getPixel(xCoord:modifiedX, yCoord: j))
            }
            var unscrambledCol = mosaicDecrypt(original: origCol, pr: pr2)
            for j in 0..<(safePrime-1) {
                var modifiedX = (x + prToThe(base: pr1, k: j)) % (safePrime - 1)
                m.setPixel(x: modifiedX, y: j, inputimg: unscrambledCol[j])
            }
        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    /*
      
      public static BufferedImage mosaicUnscrambleD2 (BufferedImage original, int pr1, int pr2) throws IOException {
            BufferedImage unscrambled = original;
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, unscrambled);

            //scramble each column
            for (int x = 0; x < safePrime - 1; x++) {
                ArrayList<BufferedImage> origCol = new ArrayList <BufferedImage> ();
                for (int j = 0; j < safePrime - 1; j++) {
                      int modifiedX = (x + (prToThe(pr1, j))) % (safePrime - 1);
                    BufferedImage c = m.getPixel(modifiedX, j);
                    origCol.add(c);
                }
               
                ArrayList<BufferedImage> unscrambledCol = mosaicDecryptCols (origCol, pr2);
                for (int j = 0; j < safePrime - 1; j++) {
                      int modifiedX = (x + (prToThe(pr1, j))) % (safePrime - 1);
                    BufferedImage newImage = unscrambledCol.get(j);
                    m.setPixel(modifiedX, j, newImage);
                }
                System.out.println("Row " + x + " unscrambled");
            }
            unscrambled = m.getMosaic();
            return unscrambled;
        }
     */
    
    private func funnyMosaicScramble(original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        var m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origRow.append(m.getPixel(xCoord:j, yCoord: y))
            }
            var scrambledRow = funnyMosaicEncrypt(original: origRow, a: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: j, y: y, inputimg: scrambledRow[j])
            }
        }
        scrambled = m.getMosaic()
        return scrambled
    }
    /*
     private static BufferedImage funnyMosaicScramble (BufferedImage original, int pr) throws IOException {
           BufferedImage scrambled = original;
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, scrambled);
           for (int y = 0; y < safePrime - 1; y++) {
                ArrayList<BufferedImage> origRow = new ArrayList<BufferedImage>();
               
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage c = m.getPixel(j, y);
                   origRow.add(c);
               }

               ArrayList<BufferedImage> scrambledRow = funnyMosaicEncrypt (origRow, pr);
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage newImage = scrambledRow.get(j);
                   
                
                   m.setPixel(j, y, newImage);
                   
               }

           }
           scrambled = m.getMosaic();
           return scrambled;
           
       }
     */
    
    private func funnyMosaicScramble2 (original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        var m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origCol.append(m.getPixel(xCoord:x, yCoord: j))
            }
            var scrambledCol = funnyMosaicEncrypt (original: origCol, a: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: x, y: j, inputimg: scrambledCol[j])
            }
        }
        scrambled = m.getMosaic()
        return scrambled
    }
    
    /*
     private static BufferedImage funnyMosaicScramble2 (BufferedImage original, int pr) throws IOException {
           BufferedImage scrambled = original;
          
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, scrambled);
           //scramble each column
           for (int x = 0; x < safePrime - 1; x++) {
               ArrayList<BufferedImage> origCol = new ArrayList<BufferedImage>();
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage c = m.getPixel(x, j);
                   origCol.add(c);
               }
              
               ArrayList<BufferedImage> scrambledCol = funnyMosaicEncrypt (origCol, pr);
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage newImage = scrambledCol.get(j);
                   m.setPixel(x, j, newImage);
               }
                 


           }
           scrambled = m.getMosaic();
           return scrambled;
         }

     */
    
    private func funnyMosaicScrambleD1(original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        var m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                var modifiedY = (y + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                origRow.append(m.getPixel(xCoord:j, yCoord: modifiedY))
            }
            var scrambledRow = funnyMosaicEncrypt(original: origRow, a: pr2)
            for j in 0..<(safePrime-1) {
                var modifiedY = (y + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                m.setPixel(x: j, y: modifiedY, inputimg: scrambledRow[j])
            }
        }
        scrambled = m.getMosaic()
        return scrambled
    }
    
    /*
     private static BufferedImage funnyMosaicScrambleD1 (BufferedImage original, int pr1, int pr2) throws IOException {
              BufferedImage scrambled = original;
             
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, scrambled);

              //scramble each row
              for (int y = 0; y < safePrime - 1; y++) {
                  ArrayList<BufferedImage> origRow = new ArrayList<BufferedImage>();
                  for (int j = 0; j < safePrime - 1; j++) {
                      int modifiedY = (y + (prToThe(j+1, pr1))) % (safePrime - 1);
                      BufferedImage c = m.getPixel(j, modifiedY);
                      origRow.add(c);
                  }
                 
                  ArrayList<BufferedImage> scrambledRow = funnyMosaicEncrypt (origRow, pr2);
                  for (int j = 0; j < safePrime - 1; j++) {
                      int modifiedY = (y + (prToThe(j+1, pr1))) % (safePrime - 1);
                      BufferedImage newImage = scrambledRow.get(j);
                      
                      m.setPixel(j, modifiedY, newImage);
                      
                  }
                 


              }
           scrambled = m.getMosaic();
              return scrambled;
          }
     
     */
    
    private func funnyMosaicScrambleD2(original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        var m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                var modifiedX = (x + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                origCol.append(m.getPixel(xCoord:modifiedX, yCoord: j))
            }
            var scrambledCol = funnyMosaicEncrypt(original: origCol, a: pr2)
            for j in 0..<(safePrime-1) {
                var modifiedX = (x + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                m.setPixel(x: modifiedX, y: j, inputimg: scrambledCol[j])
            }
        }
        scrambled = m.getMosaic()
        return scrambled
    }
    
    /*
     private static BufferedImage funnyMosaicScrambleD2 (BufferedImage original, int pr1, int pr2) throws IOException{
           BufferedImage scrambled = original;
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, scrambled);
           
           //scramble each column
           for (int x = 0; x < safePrime - 1; x++) {
               ArrayList<BufferedImage> origCol = new ArrayList<BufferedImage>();
               for (int j = 0; j < safePrime - 1; j++) {
                   int modifiedX = (x + (prToThe(j+1, pr1))) % (safePrime - 1);
                   BufferedImage c = m.getPixel(modifiedX, j);
                   origCol.add(c);
               }
              
               ArrayList<BufferedImage> scrambledCol = funnyMosaicEncrypt (origCol, pr2);
               for (int j = 0; j < safePrime - 1; j++) {
                   int modifiedX = (x + (prToThe(j+1, pr1))) % (safePrime - 1);
                   BufferedImage newImage = scrambledCol.get(j);
                   m.setPixel(modifiedX, j, newImage);
               }
             


           }
           scrambled = m.getMosaic();
           return scrambled;
     }
     */
    
    private func funnyMosaicUnscrambleRows (original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        var m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origCol.append(m.getPixel(xCoord:x, yCoord: j))
            }
            var unscrambledCol = funnyMosaicDecrypt(original: origCol, a: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: x, y: j, inputimg: unscrambledCol[j])
            }
        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    /*
     public static BufferedImage funnyMosaicUnscrambleRows (BufferedImage original, int pr) throws IOException {
           BufferedImage unscrambled = original;
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, unscrambled);

           //scramble each column
           for (int x = 0; x < safePrime - 1; x++) {
               ArrayList<BufferedImage> origCol = new ArrayList <BufferedImage> ();
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage c = m.getPixel(x, j);
                   origCol.add(c);
               }
              
               ArrayList<BufferedImage> unscrambledCol = funnyMosaicDecrypt (origCol, pr);
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage newImage = unscrambledCol.get(j);
                   m.setPixel(x, j, newImage);
               }
               System.out.println("Row " + x + " unscrambled");
           }
           unscrambled = m.getMosaic();
           return unscrambled;
         }
     
     */
    
    private func funnyMosaicUnscrambleCols (original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        var m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origRow.append(m.getPixel(xCoord:j, yCoord: y))
            }
            var unscrambledRow = funnyMosaicDecrypt(original: origRow, a: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: j, y: y, inputimg: unscrambledRow[j])
            }
        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    /*
     public static BufferedImage funnyMosaicUnscrambleCols (BufferedImage original, int pr) throws IOException {
          BufferedImage unscrambled = original;
          Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, unscrambled);
         
          //scramble each row
          for (int y = 0; y < safePrime - 1; y++) {
              ArrayList<BufferedImage> origRow = new ArrayList <BufferedImage> ();
              for (int j = 0; j < safePrime - 1; j++) {
                  BufferedImage c = m.getPixel(j, y);
                  origRow.add(c);
              }
             
              ArrayList<BufferedImage> unscrambledRow = funnyMosaicDecrypt (origRow, pr);
              for (int j = 0; j < safePrime - 1; j++) {
                  BufferedImage newImage = unscrambledRow.get(j);
                  m.setPixel(j, y, newImage);
              }
              System.out.println("Column " + y + " unscrambled");
            



          }
          unscrambled = m.getMosaic();
          return unscrambled;
      }
     */
    private func funnyMosaicUnscrambleD1 (original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        var m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                var modifiedY = (y + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                origRow.append(m.getPixel(xCoord:j, yCoord: modifiedY))
            }
            var unscrambledRow = funnyMosaicDecrypt(original: origRow, a: pr2)
            for j in 0..<(safePrime-1) {
                var modifiedY = (y + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                m.setPixel(x: j, y: modifiedY, inputimg: unscrambledRow[j])
            }
        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    /*
     public static BufferedImage funnyMosaicUnscrambleD1 (BufferedImage original, int pr1, int pr2) throws IOException {
          BufferedImage unscrambled = original;
          Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, unscrambled);

          //scramble each row
          for (int y = 0; y < safePrime - 1; y++) {
              ArrayList<BufferedImage> origRow = new ArrayList <BufferedImage> ();
              for (int j = 0; j < safePrime - 1; j++) {
                      int modifiedY = (y + (prToThe(j+1, pr1))) % (safePrime - 1);
                  BufferedImage c = m.getPixel(j, modifiedY);
                  origRow.add(c);
              }
             
              ArrayList<BufferedImage> unscrambledRow = funnyMosaicDecrypt (origRow, pr2);
              for (int j = 0; j < safePrime - 1; j++) {
                      int modifiedY = (y + (prToThe(j+1, pr1))) % (safePrime - 1);
                  BufferedImage newImage = unscrambledRow.get(j);
                  m.setPixel(j, modifiedY, newImage);
              }
              System.out.println("Column " + y + " unscrambled");
                  

          }
          unscrambled = m.getMosaic();
          return unscrambled;
      }
     */
    
    private func funnyMosaicUnscrambleD2 (original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        var m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                var modifiedX = (x + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                origCol.append(m.getPixel(xCoord:modifiedX, yCoord: j))
            }
            var unscrambledCol = funnyMosaicDecrypt(original: origCol, a: pr2)
            for j in 0..<(safePrime-1) {
                var modifiedX = (x + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                m.setPixel(x: modifiedX, y: j, inputimg: unscrambledCol[j])
            }
        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    /*
     public static BufferedImage funnyMosaicUnscrambleD2 (BufferedImage original, int pr1, int pr2) throws IOException {
          BufferedImage unscrambled = original;
          Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, unscrambled);

          //scramble each column
          for (int x = 0; x < safePrime - 1; x++) {
              ArrayList<BufferedImage> origCol = new ArrayList <BufferedImage> ();
              for (int j = 0; j < safePrime - 1; j++) {
                   int modifiedX = (x + (prToThe(j+1, pr1))) % (safePrime - 1);
                  BufferedImage c = m.getPixel(modifiedX, j);
                  origCol.add(c);
              }
             
              ArrayList<BufferedImage> unscrambledCol = funnyMosaicDecrypt (origCol, pr2);
              for (int j = 0; j < safePrime - 1; j++) {
                   int modifiedX = (x + (prToThe(j+1, pr1))) % (safePrime - 1);
                  BufferedImage newImage = unscrambledCol.get(j);
                  m.setPixel(modifiedX, j, newImage);
              }
              System.out.println("Row " + x + " unscrambled");
                   


          }
          unscrambled = m.getMosaic();
          return unscrambled;
     }
     */
    
    //now, onto layer 4 (the surface level) of the encryption/decryption functions
    
    public func enhancedMosaicEncrypt () {
        var width = (safePrime - 1) * pixelSize
        var height = (safePrime - 1) * pixelSize
        var proots: [Int] = []
        for i in 0..<(safePrime-1) {
            proots.append(i)
        }
        for i in 0..<safePrime {
            if let j = proots.firstIndex(of: ((i*i) % safePrime)) {
                proots.remove(at: j)
            }
        }
        let randomIndex1 = Int.random(in: 0..<proots.count)
        let randomIndex2 = Int.random(in: 0..<proots.count)
        let randomIndex3 = Int.random(in: 0..<proots.count)
        let randomIndex4 = Int.random(in: 0..<proots.count)
        let randomIndex5 = Int.random(in: 0..<proots.count)
        let randomIndex6 = Int.random(in: 0..<proots.count)
        let proot1 = proots[randomIndex1]
        let proot2 = proots[randomIndex2]
        let proot3 = proots[randomIndex3]
        let proot4 = proots[randomIndex4]
        let proot5 = proots[randomIndex5]
        let proot6 = proots[randomIndex6]
        var relPrimes: [Int] = []
        for i in 0..<(safePrime-1) {
            if ((i % 2 == 1) && (i != (safePrime - 1) / 2)) {
                relPrimes.append(i)
            }
        }
        let aIndex1 = Int.random(in: 0..<relPrimes.count)
        let aIndex2 = Int.random(in: 0..<relPrimes.count)
        let aIndex3 = Int.random(in: 0..<relPrimes.count)
        let aIndex4 = Int.random(in: 0..<relPrimes.count)
        let aIndex5 = Int.random(in: 0..<relPrimes.count)
        let aIndex6 = Int.random(in: 0..<relPrimes.count)
        let a1 = relPrimes[aIndex1]
        let a2 = relPrimes[aIndex2]
        let a3 = relPrimes[aIndex3]
        let a4 = relPrimes[aIndex4]
        let a5 = relPrimes[aIndex5]
        let a6 = relPrimes[aIndex6]
        tempRoots = [proot1, proot2, proot3, proot4, proot5, proot6]
        tempA = [a1, a2, a3, a4, a5, a6]
        image = resizeImage(orig: rawImage, targetWidth: width, targetHeight: height)
        var scrambledImage = mosaicScramble(original: image, pr: proot1)
        var scrambledImage2 = mosaicScramble2(original: scrambledImage, pr: proot2)
        var scrambledImage3 = mosaicScrambleD1(original: scrambledImage2, pr1: proot3, pr2: proot4)
        var scrambledImage4 = mosaicScrambleD2(original: scrambledImage3, pr1: proot5, pr2: proot6)
        var scrambledImage5 = funnyMosaicScramble(original: scrambledImage4, pr: a1)
        var scrambledImage6 = funnyMosaicScramble2 (original: scrambledImage5, pr: a2)
        var scrambledImage7 = funnyMosaicScrambleD1 (original: scrambledImage6, pr1: a3, pr2: a4)
        var scrambledImage8 = funnyMosaicScrambleD2 (original: scrambledImage7, pr1: a5, pr2: a6)
        image = scrambledImage8
        secretCode = String(proot1) + " " + String(proot2) + " " + String(proot3) + " " + String(proot4) + " " + String(proot5) + " " + String(proot6) + " " + String(a1) + " " + String(a2) + " " + String(a3) + " " + String(a4) + " " + String(a5) + " " + String(a6)
        
    }
    
    /*
     public void enhancedMosaicEncrypt () throws IOException{
                Random random = new Random();
               int width = (safePrime - 1) * pixelSize;    //width of the image
               int height = (safePrime - 1) * pixelSize;   //height of the image
               //generate the primitive roots mod safePrime
               
               ArrayList <Integer> proots = new ArrayList <Integer> ();
               for (int i = 0; i < (safePrime - 1); i++) {
                    proots.add(i);
               }
               for (int i = 0; i < safePrime; i++) {
                    int j = proots.indexOf((i*i) % safePrime);
                    if (j != -1) {
                        proots.remove(j);
                    }
                   
               }
               int randomIndex1 = random.nextInt(proots.size());
               int randomIndex2 = random.nextInt(proots.size());
               int randomIndex3 = random.nextInt(proots.size());
               int randomIndex4 = random.nextInt(proots.size());
               int randomIndex5 = random.nextInt(proots.size());
               int randomIndex6 = random.nextInt(proots.size());

               int proot1 = proots.get(randomIndex1);
               int proot2 = proots.get(randomIndex2);
               int proot3 = proots.get(randomIndex3);
               int proot4 = proots.get(randomIndex4);
               int proot5 = proots.get(randomIndex5);
               int proot6 = proots.get(randomIndex6);
               
               ArrayList <Integer> relPrimes = new ArrayList <Integer> ();
               for (int i = 0; i < (safePrime - 1); i++) {
                   if (((i % 2) == 1) && (i != (safePrime - 1) / 2)) {
                       relPrimes.add(i);
                   }
               }
               
               int aIndex1 = random.nextInt(relPrimes.size());
               int aIndex2 = random.nextInt(relPrimes.size());
               int aIndex3 = random.nextInt(relPrimes.size());
               int aIndex4 = random.nextInt(relPrimes.size());
               int aIndex5 = random.nextInt(relPrimes.size());
               int aIndex6 = random.nextInt(relPrimes.size());

               int a1 = relPrimes.get(aIndex1);
               int a2 = relPrimes.get(aIndex2);
               int a3 = relPrimes.get(aIndex3);
               int a4 = relPrimes.get(aIndex4);
               int a5 = relPrimes.get(aIndex5);
               int a6 = relPrimes.get(aIndex6);

                tempRoot1 = proot1;
                tempRoot2 = proot2;
                tempRoot3 = proot3;
                tempRoot4 = proot4;
                tempRoot5 = proot5;
                tempRoot6 = proot6;
                
                tempA1 = a1;
                tempA2 = a2;
                tempA3 = a3;
                tempA4 = a4;
                tempA5 = a5;
                tempA6 = a6;


               
               File f = null;
               
               //read image
               try{
               f = new File(fileName); //image file path
               rawImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
               rawImage = ImageIO.read(f);
               image = resizeImage(rawImage, width, height);
               System.out.println("Reading complete.");
               }catch(IOException e){
               System.out.println("Error: "+e);
               }
               
               BufferedImage scrambledImage = mosaicScramble(image, proot1);

               BufferedImage scrambledImage2 = mosaicScramble2(scrambledImage, proot2);
               
               BufferedImage scrambledImage3 = mosaicScrambleD1(scrambledImage2, proot3, proot4);

               BufferedImage scrambledImage4 = mosaicScrambleD2(scrambledImage3, proot5, proot6);
               
               BufferedImage scrambledImage5 = funnyMosaicScramble(scrambledImage4, a1);
               
               BufferedImage scrambledImage6 = funnyMosaicScramble2(scrambledImage5, a2);
               
               BufferedImage scrambledImage7 = funnyMosaicScrambleD1 (scrambledImage6, a3, a4);
               
               BufferedImage scrambledImage8 = funnyMosaicScrambleD2 (scrambledImage7, a5, a6);

               System.out.println("Image Scrambled.");
               
               image = scrambledImage8;

               ImageIO.write(image, "png", f);
               System.out.println("Image writing complete.");
               
               
               String secretCode = proot1 + " " + proot2 + " " + proot3 + " " + proot4 + " " + proot5 + " " + proot6 + " " + a1 + " " + a2 + " " + a3 + " " + a4 + " " + a5 + " " + a6;
               
               System.out.println("Your decryption code is: \n" + secretCode + ". \nKeep this code to yourself but don't lose it!");
                    
               
           }
     */
    
    public func enhancedMosaicDecrypt (pr1: Int, pr2: Int, pr3: Int, pr4: Int, pr5: Int, pr6: Int, a1: Int, a2: Int, a3: Int, a4: Int, a5: Int, a6: Int, sPrime: Int) {
        safePrime = sPrime
        var width = (safePrime - 1) * pixelSize
        var height = (safePrime - 1) * pixelSize
        image = resizeImage (orig: rawImage, targetWidth: width, targetHeight: height)
        
        var unscrambledImage1 = funnyMosaicUnscrambleD2 (original: image, pr1: a5, pr2: a6)
        var unscrambledImage2 = funnyMosaicUnscrambleD1 (original: unscrambledImage1, pr1: a3, pr2: a4)
        var unscrambledImage3 = funnyMosaicUnscrambleRows (original: unscrambledImage2, pr: a2)
        var unscrambledImage4 = funnyMosaicUnscrambleCols (original: unscrambledImage3, pr: a1)
        
        var unscrambledImage5 = mosaicUnscrambleD2 (original: unscrambledImage4, pr1: pr5, pr2: pr6)
        var unscrambledImage6 = mosaicUnscrambleD1 (original: unscrambledImage5, pr1: pr3, pr2: pr4)
        var unscrambledImage7 = mosaicUnscrambleRows (original: unscrambledImage6, pr: pr2)
        var unscrambledImage8 = mosaicUnscrambleCols (original: unscrambledImage7, pr: pr1)
        
        image = unscrambledImage8
        
    }
    /*
     public void enhancedMosaicDecrypt () throws IOException{
             Scanner scan = new Scanner(System.in);

         System.out.println("Enter the exact safe prime used: ");
         String im = scan.nextLine();
             safePrime = Integer.parseInt(im);
             
             int width = (safePrime - 1) * pixelSize;    //width of the image
             int height = (safePrime - 1) * pixelSize;   //height of the image
             BufferedImage image = null;
             File f = null;
            
             //read image
             try{
               f = new File(fileName); //image file path
               BufferedImage rawImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
               rawImage = ImageIO.read(f);
               image = resizeImage(rawImage, width, height);
               System.out.println("Reading complete.");
             }catch(IOException e){
               System.out.println("Error: "+e);
             }
             
             
            
             System.out.println("Enter the decryption code for that image: ");
            
             String codestring = scan.nextLine();
             String[] rootsArray = codestring.split(" ");
         
             int root1 = Integer.parseInt(rootsArray[0]);
             int root2 = Integer.parseInt(rootsArray[1]);
             int root3 = Integer.parseInt(rootsArray[2]);
             int root4 = Integer.parseInt(rootsArray[3]);
             int root5 = Integer.parseInt(rootsArray[4]);
             int root6 = Integer.parseInt(rootsArray[5]);

             int a1 = Integer.parseInt(rootsArray[6]);
             int a2 = Integer.parseInt(rootsArray[7]);
             int a3 = Integer.parseInt(rootsArray[8]);
             int a4 = Integer.parseInt(rootsArray[9]);
             int a5 = Integer.parseInt(rootsArray[10]);
             int a6 = Integer.parseInt(rootsArray[11]);


             BufferedImage unscrambledImage1 = funnyMosaicUnscrambleD2 (image, a5, a6);
             BufferedImage unscrambledImage2 = funnyMosaicUnscrambleD1 (unscrambledImage1, a3, a4);
            BufferedImage unscrambledImage3 = funnyMosaicUnscrambleRows (unscrambledImage2, a2);
            BufferedImage unscrambledImage4 = funnyMosaicUnscrambleCols (unscrambledImage3, a1);
             
             BufferedImage unscrambledImage5 = mosaicUnscrambleD2 (unscrambledImage4, root5, root6);
             BufferedImage unscrambledImage6 = mosaicUnscrambleD1 (unscrambledImage5, root3, root4);
             BufferedImage unscrambledImage7 = mosaicUnscrambleRows (unscrambledImage6, root2);
             BufferedImage unscrambledImage8 = mosaicUnscrambleCols (unscrambledImage7, root1);

             System.out.println("Image unscrambled.");
            
                            
             ImageIO.write(unscrambledImage8, "png", f);
             System.out.println("Writing complete.");
             
             image = unscrambledImage8;
                    
               
              }
     */
    
    
    
}

//implement the Mosaic class

class Mosaic {
    private var mosaicImages: [Image<RGBA<UInt8>>] = []
    private var dimension: Int = 0
    private var pixelSize: Int = 0
    //again, initialize these as black
    private var orig:Image = Image<RGBA<UInt8>>(width: 1000, height: 1000, pixel: .black)
    private var origMosaic:Image = Image<RGBA<UInt8>>(width: 1000, height: 1000, pixel: .black)
    private var mosaic:Image = Image<RGBA<UInt8>>(width: 1000, height: 1000, pixel: .black)
    
    //constructor
    init (spd: Int, ps: Int, inputimg: Image<RGBA<UInt8>>) {
        dimension = spd
        pixelSize = ps
        orig = inputimg
        fractionate()
    }
    
    private func fractionate() {
        mosaic = resizeImage(orig: orig, targetWidth: dimension*pixelSize, targetHeight: dimension*pixelSize)
        origMosaic = resizeImage(orig: orig, targetWidth: dimension*pixelSize, targetHeight: dimension*pixelSize)
        for x in 0..<dimension {
            for y in 0..<dimension {
                let subSlice: ImageSlice<RGBA<UInt8>> = origMosaic[x*pixelSize..<(x+1)*pixelSize, y*pixelSize..<(y+1)*pixelSize]
                let sub = Image<RGBA<UInt8>>(subSlice)
                mosaicImages.append(sub)
                
            }
        }
        
    }
    
    public func getMosaic() -> Image<RGBA<UInt8>> {
        return mosaic
    }
    
    public func getMosaicImages() -> [Image<RGBA<UInt8>>] {
        return mosaicImages
    }
    
    public func setPixel(x: Int, y: Int, inputimg: Image<RGBA<UInt8>>) {
        for i in x*pixelSize..<(x+1)*pixelSize {
            for j in y*pixelSize..<(y+1)*pixelSize {
                var newRGB = inputimg[i % pixelSize, j % pixelSize]
                mosaic[i, j] = newRGB
            }
        }
    }
    
    public func getPixel (xCoord: Int, yCoord: Int) -> Image<RGBA<UInt8>> {
        return mosaicImages[dimension * xCoord + yCoord]
    }

    private func resizeImage (orig: Image<RGBA<UInt8>>, targetWidth: Int, targetHeight: Int) -> Image<RGBA<UInt8>> {
        return orig.resizedTo(width: targetWidth, height: targetHeight)
    }
    
    
    
    
}

/*class Mosaic  {
        private ArrayList<BufferedImage> mosaicImages = new ArrayList<BufferedImage>();
        private int dimension;
        private int pixelSize;
        private BufferedImage orig;
        private BufferedImage origMosaic;
        private BufferedImage mosaic;
        public Mosaic4 (int spd, int ps, BufferedImage b) throws IOException {
            dimension = spd;
            pixelSize = ps;
            orig = b;
            fractionate();

        }
        
        private void fractionate () throws IOException {
            mosaic = resizeImage(orig, dimension*pixelSize, dimension*pixelSize);
            origMosaic = resizeImage(orig, dimension*pixelSize, dimension*pixelSize);

            for (int x = 0; x < dimension; x++) {
              for (int y = 0; y < dimension; y++) {

                  //compute average RGB of cell
                  BufferedImage sub = origMosaic.getSubimage(x * pixelSize, y*pixelSize, pixelSize, pixelSize);

                  mosaicImages.add(sub);
              }
          }
        }
        
        public BufferedImage getMosaic () {
            return mosaic;
        }
        
        public ArrayList<BufferedImage> getMosaicImages() {
            return mosaicImages;
        }
        
        public void setPixel (int x, int y, BufferedImage bi) {
            
            for (int i = x*pixelSize; i < (x+1)*pixelSize; i++) {
            for (int j = y*pixelSize; j < (y+1)*pixelSize; j++) {
                int newRGB = bi.getRGB(i % pixelSize, j % pixelSize);
                mosaic.setRGB(i, j, newRGB);
            }
         }
        }
        
        public BufferedImage getPixel (int xCoord, int yCoord) {
            BufferedImage returnedImage = mosaicImages.get(dimension * xCoord + yCoord);
            return returnedImage;
        }
        
        static BufferedImage resizeImage(BufferedImage originalImage, int targetWidth, int targetHeight) throws IOException {
                BufferedImage resizedImage = new BufferedImage(targetWidth, targetHeight, BufferedImage.TYPE_INT_RGB);
                Graphics2D graphics2D = resizedImage.createGraphics();
                graphics2D.drawImage(originalImage, 0, 0, targetWidth, targetHeight, null);
                graphics2D.dispose();
                return resizedImage;
            }
        
        private static Color computeAverage (BufferedImage bi) {
            long rSum = 0;
            long gSum = 0;
            long bSum = 0;
            for (int i = 0; i < bi.getWidth(); i++) {
                for (int j = 0; j < bi.getHeight(); j++) {
                    Color c = new Color (bi.getRGB(i, j));
                    rSum += c.getRed();
                    gSum += c.getGreen();
                    bSum += c.getBlue();
                }
            }
            int totalPixels = bi.getWidth() * bi.getHeight();
            return new Color((int) (rSum / totalPixels), (int) (gSum / totalPixels), (int) (bSum / totalPixels));
        }
}*/

/*    public void enhancedMosaicEncrypt () throws IOException{
           Random random = new Random();
          int width = (safePrime - 1) * pixelSize;    //width of the image
          int height = (safePrime - 1) * pixelSize;   //height of the image
          //generate the primitive roots mod safePrime
          
          ArrayList <Integer> proots = new ArrayList <Integer> ();
          for (int i = 0; i < (safePrime - 1); i++) {
               proots.add(i);
          }
          for (int i = 0; i < safePrime; i++) {
               int j = proots.indexOf((i*i) % safePrime);
               if (j != -1) {
                   proots.remove(j);
               }
              
          }
          int randomIndex1 = random.nextInt(proots.size());
          int randomIndex2 = random.nextInt(proots.size());
          int randomIndex3 = random.nextInt(proots.size());
          int randomIndex4 = random.nextInt(proots.size());
          int randomIndex5 = random.nextInt(proots.size());
          int randomIndex6 = random.nextInt(proots.size());

          int proot1 = proots.get(randomIndex1);
          int proot2 = proots.get(randomIndex2);
          int proot3 = proots.get(randomIndex3);
          int proot4 = proots.get(randomIndex4);
          int proot5 = proots.get(randomIndex5);
          int proot6 = proots.get(randomIndex6);
          
          ArrayList <Integer> relPrimes = new ArrayList <Integer> ();
          for (int i = 0; i < (safePrime - 1); i++) {
              if (((i % 2) == 1) && (i != (safePrime - 1) / 2)) {
                  relPrimes.add(i);
              }
          }
          
          int aIndex1 = random.nextInt(relPrimes.size());
          int aIndex2 = random.nextInt(relPrimes.size());
          int aIndex3 = random.nextInt(relPrimes.size());
          int aIndex4 = random.nextInt(relPrimes.size());
          int aIndex5 = random.nextInt(relPrimes.size());
          int aIndex6 = random.nextInt(relPrimes.size());

          int a1 = relPrimes.get(aIndex1);
          int a2 = relPrimes.get(aIndex2);
          int a3 = relPrimes.get(aIndex3);
          int a4 = relPrimes.get(aIndex4);
          int a5 = relPrimes.get(aIndex5);
          int a6 = relPrimes.get(aIndex6);

           tempRoot1 = proot1;
           tempRoot2 = proot2;
           tempRoot3 = proot3;
           tempRoot4 = proot4;
           tempRoot5 = proot5;
           tempRoot6 = proot6;
           
           tempA1 = a1;
           tempA2 = a2;
           tempA3 = a3;
           tempA4 = a4;
           tempA5 = a5;
           tempA6 = a6;


          
          File f = null;
          
          //read image
          try{
          f = new File(fileName); //image file path
          rawImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
          rawImage = ImageIO.read(f);
          image = resizeImage(rawImage, width, height);
          System.out.println("Reading complete.");
          }catch(IOException e){
          System.out.println("Error: "+e);
          }
          
          BufferedImage scrambledImage = mosaicScramble(image, proot1);

          BufferedImage scrambledImage2 = mosaicScramble2(scrambledImage, proot2);
          
          BufferedImage scrambledImage3 = mosaicScrambleD1(scrambledImage2, proot3, proot4);

          BufferedImage scrambledImage4 = mosaicScrambleD2(scrambledImage3, proot5, proot6);
          
          BufferedImage scrambledImage5 = funnyMosaicScramble(scrambledImage4, a1);
          
          BufferedImage scrambledImage6 = funnyMosaicScramble2(scrambledImage5, a2);
          
          BufferedImage scrambledImage7 = funnyMosaicScrambleD1 (scrambledImage6, a3, a4);
          
          BufferedImage scrambledImage8 = funnyMosaicScrambleD2 (scrambledImage7, a5, a6);

          System.out.println("Image Scrambled.");
          
          image = scrambledImage8;

          ImageIO.write(image, "png", f);
          System.out.println("Image writing complete.");
          
          
          String secretCode = proot1 + " " + proot2 + " " + proot3 + " " + proot4 + " " + proot5 + " " + proot6 + " " + a1 + " " + a2 + " " + a3 + " " + a4 + " " + a5 + " " + a6;
          
          System.out.println("Your decryption code is: \n" + secretCode + ". \nKeep this code to yourself but don't lose it!");
               
          
      }
    
     
     public void enhancedMosaicDecrypt () throws IOException{
             Scanner scan = new Scanner(System.in);

         System.out.println("Enter the exact safe prime used: ");
         String im = scan.nextLine();
             safePrime = Integer.parseInt(im);
             
             int width = (safePrime - 1) * pixelSize;    //width of the image
             int height = (safePrime - 1) * pixelSize;   //height of the image
             BufferedImage image = null;
             File f = null;
            
             //read image
             try{
               f = new File(fileName); //image file path
               BufferedImage rawImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
               rawImage = ImageIO.read(f);
               image = resizeImage(rawImage, width, height);
               System.out.println("Reading complete.");
             }catch(IOException e){
               System.out.println("Error: "+e);
             }
             
             
            
             System.out.println("Enter the decryption code for that image: ");
            
             String codestring = scan.nextLine();
             String[] rootsArray = codestring.split(" ");
         
             int root1 = Integer.parseInt(rootsArray[0]);
             int root2 = Integer.parseInt(rootsArray[1]);
             int root3 = Integer.parseInt(rootsArray[2]);
             int root4 = Integer.parseInt(rootsArray[3]);
             int root5 = Integer.parseInt(rootsArray[4]);
             int root6 = Integer.parseInt(rootsArray[5]);

             int a1 = Integer.parseInt(rootsArray[6]);
             int a2 = Integer.parseInt(rootsArray[7]);
             int a3 = Integer.parseInt(rootsArray[8]);
             int a4 = Integer.parseInt(rootsArray[9]);
             int a5 = Integer.parseInt(rootsArray[10]);
             int a6 = Integer.parseInt(rootsArray[11]);


             BufferedImage unscrambledImage1 = funnyMosaicUnscrambleD2 (image, a5, a6);
             BufferedImage unscrambledImage2 = funnyMosaicUnscrambleD1 (unscrambledImage1, a3, a4);
            BufferedImage unscrambledImage3 = funnyMosaicUnscrambleRows (unscrambledImage2, a2);
            BufferedImage unscrambledImage4 = funnyMosaicUnscrambleCols (unscrambledImage3, a1);
             
             BufferedImage unscrambledImage5 = mosaicUnscrambleD2 (unscrambledImage4, root5, root6);
             BufferedImage unscrambledImage6 = mosaicUnscrambleD1 (unscrambledImage5, root3, root4);
             BufferedImage unscrambledImage7 = mosaicUnscrambleRows (unscrambledImage6, root2);
             BufferedImage unscrambledImage8 = mosaicUnscrambleCols (unscrambledImage7, root1);

             System.out.println("Image unscrambled.");
            
                            
             ImageIO.write(unscrambledImage8, "png", f);
             System.out.println("Writing complete.");
             
             image = unscrambledImage8;
                    
               
              }
     
     
 
     private static int prToThe (int base, int k) {
         int value = 1;
         for (int i = 0; i < k; i++) {
             value*=base;
             value%=safePrime;
         }
         return value;
     }
     
     static BufferedImage resizeImage(BufferedImage originalImage, int targetWidth, int targetHeight) throws IOException {
         BufferedImage resizedImage = new BufferedImage(targetWidth, targetHeight, BufferedImage.TYPE_INT_RGB);
         Graphics2D graphics2D = resizedImage.createGraphics();
         graphics2D.drawImage(originalImage, 0, 0, targetWidth, targetHeight, null);
         graphics2D.dispose();
         return resizedImage;
     }
     
     public static int discreteLogBasePrModsafePrime (int base, int k) {
            int value = 0;
            for (int i = 0; i < safePrime; i++) {
                if (prToThe(base, i) % safePrime == k) {
                    value = i;
                    break;
                }
            }
            return value;
        }
     
     public static int discreteLogBasePrModsafePrime_ (int base, int k) {
           return discreteLogarithm(base, k, safePrime);
       }
     
     static int discreteLogarithm(int a, int b, int m)
     {
         int n = (int) (Math.sqrt (m) + 1);
  
         // Calculate a ^ n
         int an = 1;
         for (int i = 0; i < n; ++i)
             an = (an * a) % m;
  
         int[] value=new int[m];
  
         // Store all values of a^(n*i) of LHS
         for (int i = 1, cur = an; i <= n; ++i)
         {
             if (value[ cur ] == 0)
                 value[ cur ] = i;
             cur = (cur * an) % m;
         }
  
         for (int i = 0, cur = b; i <= n; ++i)
         {
             // Calculate (a ^ j) * b and check
             // for collision
             if (value[cur] > 0)
             {
                 int ans = value[cur] * n - i;
                 if (ans < m)
                     return ans;
             }
             cur = (cur * a) % m;
         }
         return -1;
     }
        
    
        
        private static ArrayList<BufferedImage> mosaicEncrypt (ArrayList <BufferedImage> original, int pr) {
           ArrayList<BufferedImage> newArr = new ArrayList<BufferedImage>();
           for (int i = 0; i < original.size(); i++) {
               newArr.add(original.get(prToThe(pr, i) - 1));

           }
           return newArr;
       }
       
       private static ArrayList<BufferedImage> mosaicEncrypt2 (ArrayList <BufferedImage> original, int pr) {
           ArrayList<BufferedImage> newArr = new ArrayList<BufferedImage>();
           for (int i = 0; i < original.size(); i++) {
               newArr.add(original.get(prToThe(pr, i) - 1));
           }
           return newArr;
       }
       
       
     private static ArrayList<BufferedImage> funnyMosaicEncrypt (ArrayList <BufferedImage> original, int a) {
         //a is relatively prime to safePrime - 1
         ArrayList<BufferedImage> newArr = new ArrayList<BufferedImage>();
         for (int i = 0; i < original.size(); i++) {
             newArr.add(original.get(prToThe(i+1, a) - 1));

         }
         return newArr;
     }
       
      //use pr1
        public static ArrayList<BufferedImage> mosaicDecryptRows (ArrayList <BufferedImage> original, int pr) {
            ArrayList<BufferedImage> newArr = new ArrayList<BufferedImage>();
            for (int i = 0; i < original.size(); i++) {
               
                newArr.add(original.get(discreteLogBasePrModsafePrime_(pr, i+1) % (safePrime - 1)));
            }
            return newArr;
        }
        
        //use pr2
        public static ArrayList<BufferedImage> mosaicDecryptCols (ArrayList <BufferedImage> original, int pr) {
            ArrayList<BufferedImage> newArr = new ArrayList<BufferedImage>();
            for (int i = 0; i < original.size(); i++) {
                newArr.add(original.get(discreteLogBasePrModsafePrime_(pr, i+1) % (safePrime - 1)));
            }
            return newArr;
        }
        
        private static ArrayList<BufferedImage> funnyMosaicDecrypt (ArrayList <BufferedImage> original, int a) {
         //a is relatively prime to safePrime - 1
            ArrayList<BufferedImage> newArr = new ArrayList<BufferedImage>();
          for (int i = 0; i < original.size() - 1; i++) {
              newArr.add(original.get(computeNthRootModSafePrime(a, i+1) - 1));
          }
          newArr.add(original.get(safePrime - 2));
          return newArr;
     }
        
        public static int computeNthRootModSafePrime (int n, int origNum) {
         int result = -1;
         for (int i = 0; i < safePrime; i++) {
             if (prToThe(i, n) == origNum) {
                 result = i;
                 break;
             }
         }
         return result;
         
     }
     
       
        private static BufferedImage mosaicScramble (BufferedImage original, int pr) throws IOException {
           BufferedImage scrambled = original;
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, scrambled);
           //scramble each row
           for (int y = 0; y < safePrime - 1; y++) {
                ArrayList<BufferedImage> origRow = new ArrayList<BufferedImage>();
               
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage c = m.getPixel(j, y);
                   origRow.add(c);
               }

               for (BufferedImage bi : origRow) {
               }
               
               //System.out.println();
               
               //line #1
               ArrayList<BufferedImage> scrambledRow = mosaicEncrypt (origRow, pr);
               
               //this for loop used for testing - outputs the correct and
               //expected values for scrambledRow
               for (int k = 0; k < safePrime - 1; k++) {
               }
               
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage newImage = scrambledRow.get(j);
                   
                   //this line used for testing - somehow outputs  different values for scrambledRow
                   //despite it being the same code to loop through the arraylist of size safeprime - 1
                   //computeAverage function does NOT change either newImage or scrambledRow
                   //nor did I ever change the scrambledRow arraylist in between this loop and line #1
                   //does .get somehow change the arraylist values?
                   
                   m.setPixel(j, y, newImage);
                   
               }

               
             
           }
           scrambled = m.getMosaic();
           return scrambled;
           
       }
   

     private static BufferedImage mosaicScramble2 (BufferedImage original, int pr) throws IOException {
       BufferedImage scrambled = original;
      
       Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, scrambled);
       //scramble each column
       for (int x = 0; x < safePrime - 1; x++) {
           ArrayList<BufferedImage> origCol = new ArrayList<BufferedImage>();
           for (int j = 0; j < safePrime - 1; j++) {
               BufferedImage c = m.getPixel(x, j);
               origCol.add(c);
           }
          
           ArrayList<BufferedImage> scrambledCol = mosaicEncrypt2 (origCol, pr);
           for (int j = 0; j < safePrime - 1; j++) {
               BufferedImage newImage = scrambledCol.get(j);
               m.setPixel(x, j, newImage);
           }
         


       }
       scrambled = m.getMosaic();
       return scrambled;
     }
       
     private static BufferedImage mosaicScrambleD1 (BufferedImage original, int pr1, int pr2) throws IOException {
          BufferedImage scrambled = original;
         
       Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, scrambled);

          //scramble each row
          for (int y = 0; y < safePrime - 1; y++) {
              ArrayList<BufferedImage> origRow = new ArrayList<BufferedImage>();
              for (int j = 0; j < safePrime - 1; j++) {
                  int modifiedY = (y + (prToThe(pr1, j))) % (safePrime - 1);
                  BufferedImage c = m.getPixel(j, modifiedY);
                  origRow.add(c);
              }
             
              ArrayList<BufferedImage> scrambledRow = mosaicEncrypt (origRow, pr2);
              for (int j = 0; j < safePrime - 1; j++) {
                  int modifiedY = (y + (prToThe(pr1, j))) % (safePrime - 1);
                  BufferedImage newImage = scrambledRow.get(j);
                  
                  m.setPixel(j, modifiedY, newImage);
                  
              }
             


          }
       scrambled = m.getMosaic();
          return scrambled;
      }
   
     private static BufferedImage mosaicScrambleD2 (BufferedImage original, int pr1, int pr2) throws IOException{
           BufferedImage scrambled = original;
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, scrambled);
           
           //scramble each column
           for (int x = 0; x < safePrime - 1; x++) {
               ArrayList<BufferedImage> origCol = new ArrayList<BufferedImage>();
               for (int j = 0; j < safePrime - 1; j++) {
                   int modifiedX = (x + (prToThe(pr1, j))) % (safePrime - 1);
                   BufferedImage c = m.getPixel(modifiedX, j);
                   origCol.add(c);
               }
              
               ArrayList<BufferedImage> scrambledCol = mosaicEncrypt2 (origCol, pr2);
               for (int j = 0; j < safePrime - 1; j++) {
                   int modifiedX = (x + (prToThe(pr1, j))) % (safePrime - 1);
                   BufferedImage newImage = scrambledCol.get(j);
                   m.setPixel(modifiedX, j, newImage);
               }
             


           }
           scrambled = m.getMosaic();
           return scrambled;
      }
    


     private static BufferedImage funnyMosaicScramble (BufferedImage original, int pr) throws IOException {
           BufferedImage scrambled = original;
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, scrambled);
           for (int y = 0; y < safePrime - 1; y++) {
                ArrayList<BufferedImage> origRow = new ArrayList<BufferedImage>();
               
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage c = m.getPixel(j, y);
                   origRow.add(c);
               }

               ArrayList<BufferedImage> scrambledRow = funnyMosaicEncrypt (origRow, pr);
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage newImage = scrambledRow.get(j);
                   
                
                   m.setPixel(j, y, newImage);
                   
               }

           }
           scrambled = m.getMosaic();
           return scrambled;
           
       }
     
     private static BufferedImage funnyMosaicScramble2 (BufferedImage original, int pr) throws IOException {
           BufferedImage scrambled = original;
          
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, scrambled);
           //scramble each column
           for (int x = 0; x < safePrime - 1; x++) {
               ArrayList<BufferedImage> origCol = new ArrayList<BufferedImage>();
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage c = m.getPixel(x, j);
                   origCol.add(c);
               }
              
               ArrayList<BufferedImage> scrambledCol = funnyMosaicEncrypt (origCol, pr);
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage newImage = scrambledCol.get(j);
                   m.setPixel(x, j, newImage);
               }
                 


           }
           scrambled = m.getMosaic();
           return scrambled;
         }
     
     private static BufferedImage funnyMosaicScrambleD1 (BufferedImage original, int pr1, int pr2) throws IOException {
              BufferedImage scrambled = original;
             
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, scrambled);

              //scramble each row
              for (int y = 0; y < safePrime - 1; y++) {
                  ArrayList<BufferedImage> origRow = new ArrayList<BufferedImage>();
                  for (int j = 0; j < safePrime - 1; j++) {
                      int modifiedY = (y + (prToThe(j+1, pr1))) % (safePrime - 1);
                      BufferedImage c = m.getPixel(j, modifiedY);
                      origRow.add(c);
                  }
                 
                  ArrayList<BufferedImage> scrambledRow = funnyMosaicEncrypt (origRow, pr2);
                  for (int j = 0; j < safePrime - 1; j++) {
                      int modifiedY = (y + (prToThe(j+1, pr1))) % (safePrime - 1);
                      BufferedImage newImage = scrambledRow.get(j);
                      
                      m.setPixel(j, modifiedY, newImage);
                      
                  }
                 


              }
           scrambled = m.getMosaic();
              return scrambled;
          }
     
     private static BufferedImage funnyMosaicScrambleD2 (BufferedImage original, int pr1, int pr2) throws IOException{
           BufferedImage scrambled = original;
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, scrambled);
           
           //scramble each column
           for (int x = 0; x < safePrime - 1; x++) {
               ArrayList<BufferedImage> origCol = new ArrayList<BufferedImage>();
               for (int j = 0; j < safePrime - 1; j++) {
                   int modifiedX = (x + (prToThe(j+1, pr1))) % (safePrime - 1);
                   BufferedImage c = m.getPixel(modifiedX, j);
                   origCol.add(c);
               }
              
               ArrayList<BufferedImage> scrambledCol = funnyMosaicEncrypt (origCol, pr2);
               for (int j = 0; j < safePrime - 1; j++) {
                   int modifiedX = (x + (prToThe(j+1, pr1))) % (safePrime - 1);
                   BufferedImage newImage = scrambledCol.get(j);
                   m.setPixel(modifiedX, j, newImage);
               }
             


           }
           scrambled = m.getMosaic();
           return scrambled;
     }

 public static BufferedImage mosaicUnscrambleRows (BufferedImage original, int pr) throws IOException {
       BufferedImage unscrambled = original;
       Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, unscrambled);

       //scramble each column
       for (int x = 0; x < safePrime - 1; x++) {
           ArrayList<BufferedImage> origCol = new ArrayList <BufferedImage> ();
           for (int j = 0; j < safePrime - 1; j++) {
               BufferedImage c = m.getPixel(x, j);
               origCol.add(c);
           }
          
           ArrayList<BufferedImage> unscrambledCol = mosaicDecryptCols (origCol, pr);
           for (int j = 0; j < safePrime - 1; j++) {
               BufferedImage newImage = unscrambledCol.get(j);
               m.setPixel(x, j, newImage);
           }
           System.out.println("Row " + x + " unscrambled");
 
 }
       unscrambled = m.getMosaic();
       return unscrambled;
     }

     public static BufferedImage mosaicUnscrambleCols (BufferedImage original, int pr) throws IOException {
           BufferedImage unscrambled = original;
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, unscrambled);
          
           //scramble each row
           for (int y = 0; y < safePrime - 1; y++) {
               ArrayList<BufferedImage> origRow = new ArrayList <BufferedImage> ();
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage c = m.getPixel(j, y);
                   origRow.add(c);
               }
              
               ArrayList<BufferedImage> unscrambledRow = mosaicDecryptRows (origRow, pr);
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage newImage = unscrambledRow.get(j);
                   m.setPixel(j, y, newImage);
               }
               System.out.println("Column " + y + " unscrambled");
               



           }
           unscrambled = m.getMosaic();
           return unscrambled;
       }
     
     public static BufferedImage mosaicUnscrambleD1 (BufferedImage original, int pr1, int pr2) throws IOException {
            BufferedImage unscrambled = original;
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, unscrambled);

            //scramble each row
            for (int y = 0; y < safePrime - 1; y++) {
                ArrayList<BufferedImage> origRow = new ArrayList <BufferedImage> ();
                for (int j = 0; j < safePrime - 1; j++) {
                       int modifiedY = (y + (prToThe(pr1, j))) % (safePrime - 1);
                    BufferedImage c = m.getPixel(j, modifiedY);
                    origRow.add(c);
                }
               
                ArrayList<BufferedImage> unscrambledRow = mosaicDecryptRows (origRow, pr2);
                for (int j = 0; j < safePrime - 1; j++) {
                       int modifiedY = (y + (prToThe(pr1, j))) % (safePrime - 1);
                    BufferedImage newImage = unscrambledRow.get(j);
                    m.setPixel(j, modifiedY, newImage);
                }
                System.out.println("Column " + y + " unscrambled");
                    


            }
            unscrambled = m.getMosaic();
            return unscrambled;
        }
      
      public static BufferedImage mosaicUnscrambleD2 (BufferedImage original, int pr1, int pr2) throws IOException {
            BufferedImage unscrambled = original;
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, unscrambled);

            //scramble each column
            for (int x = 0; x < safePrime - 1; x++) {
                ArrayList<BufferedImage> origCol = new ArrayList <BufferedImage> ();
                for (int j = 0; j < safePrime - 1; j++) {
                      int modifiedX = (x + (prToThe(pr1, j))) % (safePrime - 1);
                    BufferedImage c = m.getPixel(modifiedX, j);
                    origCol.add(c);
                }
               
                ArrayList<BufferedImage> unscrambledCol = mosaicDecryptCols (origCol, pr2);
                for (int j = 0; j < safePrime - 1; j++) {
                      int modifiedX = (x + (prToThe(pr1, j))) % (safePrime - 1);
                    BufferedImage newImage = unscrambledCol.get(j);
                    m.setPixel(modifiedX, j, newImage);
                }
                System.out.println("Row " + x + " unscrambled");
            }
            unscrambled = m.getMosaic();
            return unscrambled;
        }
      
      public static BufferedImage funnyMosaicUnscrambleRows (BufferedImage original, int pr) throws IOException {
            BufferedImage unscrambled = original;
            Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, unscrambled);

            //scramble each column
            for (int x = 0; x < safePrime - 1; x++) {
                ArrayList<BufferedImage> origCol = new ArrayList <BufferedImage> ();
                for (int j = 0; j < safePrime - 1; j++) {
                    BufferedImage c = m.getPixel(x, j);
                    origCol.add(c);
                }
               
                ArrayList<BufferedImage> unscrambledCol = funnyMosaicDecrypt (origCol, pr);
                for (int j = 0; j < safePrime - 1; j++) {
                    BufferedImage newImage = unscrambledCol.get(j);
                    m.setPixel(x, j, newImage);
                }
                System.out.println("Row " + x + " unscrambled");
            }
            unscrambled = m.getMosaic();
            return unscrambled;
          }
      
      public static BufferedImage funnyMosaicUnscrambleCols (BufferedImage original, int pr) throws IOException {
           BufferedImage unscrambled = original;
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, unscrambled);
          
           //scramble each row
           for (int y = 0; y < safePrime - 1; y++) {
               ArrayList<BufferedImage> origRow = new ArrayList <BufferedImage> ();
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage c = m.getPixel(j, y);
                   origRow.add(c);
               }
              
               ArrayList<BufferedImage> unscrambledRow = funnyMosaicDecrypt (origRow, pr);
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage newImage = unscrambledRow.get(j);
                   m.setPixel(j, y, newImage);
               }
               System.out.println("Column " + y + " unscrambled");
             



           }
           unscrambled = m.getMosaic();
           return unscrambled;
       }
      
      public static BufferedImage funnyMosaicUnscrambleD1 (BufferedImage original, int pr1, int pr2) throws IOException {
           BufferedImage unscrambled = original;
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, unscrambled);

           //scramble each row
           for (int y = 0; y < safePrime - 1; y++) {
               ArrayList<BufferedImage> origRow = new ArrayList <BufferedImage> ();
               for (int j = 0; j < safePrime - 1; j++) {
                       int modifiedY = (y + (prToThe(j+1, pr1))) % (safePrime - 1);
                   BufferedImage c = m.getPixel(j, modifiedY);
                   origRow.add(c);
               }
              
               ArrayList<BufferedImage> unscrambledRow = funnyMosaicDecrypt (origRow, pr2);
               for (int j = 0; j < safePrime - 1; j++) {
                       int modifiedY = (y + (prToThe(j+1, pr1))) % (safePrime - 1);
                   BufferedImage newImage = unscrambledRow.get(j);
                   m.setPixel(j, modifiedY, newImage);
               }
               System.out.println("Column " + y + " unscrambled");
                   

           }
           unscrambled = m.getMosaic();
           return unscrambled;
       }
      
      public static BufferedImage funnyMosaicUnscrambleD2 (BufferedImage original, int pr1, int pr2) throws IOException {
           BufferedImage unscrambled = original;
           Mosaic4 m = new Mosaic4 (safePrime - 1, pixelSize, unscrambled);

           //scramble each column
           for (int x = 0; x < safePrime - 1; x++) {
               ArrayList<BufferedImage> origCol = new ArrayList <BufferedImage> ();
               for (int j = 0; j < safePrime - 1; j++) {
                    int modifiedX = (x + (prToThe(j+1, pr1))) % (safePrime - 1);
                   BufferedImage c = m.getPixel(modifiedX, j);
                   origCol.add(c);
               }
              
               ArrayList<BufferedImage> unscrambledCol = funnyMosaicDecrypt (origCol, pr2);
               for (int j = 0; j < safePrime - 1; j++) {
                    int modifiedX = (x + (prToThe(j+1, pr1))) % (safePrime - 1);
                   BufferedImage newImage = unscrambledCol.get(j);
                   m.setPixel(modifiedX, j, newImage);
               }
               System.out.println("Row " + x + " unscrambled");
                    


           }
           unscrambled = m.getMosaic();
           return unscrambled;
      }

 }

 class Mosaic4 {
         private ArrayList<BufferedImage> mosaicImages = new ArrayList<BufferedImage>();
         private int dimension;
         private int pixelSize;
         private BufferedImage orig;
         private BufferedImage origMosaic;
         private BufferedImage mosaic;
         public Mosaic4 (int spd, int ps, BufferedImage b) throws IOException {
             dimension = spd;
             pixelSize = ps;
             orig = b;
             fractionate();

         }
         
         private void fractionate () throws IOException {
             mosaic = resizeImage(orig, dimension*pixelSize, dimension*pixelSize);
             origMosaic = resizeImage(orig, dimension*pixelSize, dimension*pixelSize);

             for (int x = 0; x < dimension; x++) {
               for (int y = 0; y < dimension; y++) {

                   //compute average RGB of cell
                   BufferedImage sub = origMosaic.getSubimage(x * pixelSize, y*pixelSize, pixelSize, pixelSize);

                   mosaicImages.add(sub);
               }
           }
         }
         
         public BufferedImage getMosaic () {
             return mosaic;
         }
         
         public ArrayList<BufferedImage> getMosaicImages() {
             return mosaicImages;
         }
         
         public void setPixel (int x, int y, BufferedImage bi) {
             
             for (int i = x*pixelSize; i < (x+1)*pixelSize; i++) {
             for (int j = y*pixelSize; j < (y+1)*pixelSize; j++) {
                 int newRGB = bi.getRGB(i % pixelSize, j % pixelSize);
                 mosaic.setRGB(i, j, newRGB);
             }
          }
         }
         
         public BufferedImage getPixel (int xCoord, int yCoord) {
             BufferedImage returnedImage = mosaicImages.get(dimension * xCoord + yCoord);
             return returnedImage;
         }
         
         static BufferedImage resizeImage(BufferedImage originalImage, int targetWidth, int targetHeight) throws IOException {
                 BufferedImage resizedImage = new BufferedImage(targetWidth, targetHeight, BufferedImage.TYPE_INT_RGB);
                 Graphics2D graphics2D = resizedImage.createGraphics();
                 graphics2D.drawImage(originalImage, 0, 0, targetWidth, targetHeight, null);
                 graphics2D.dispose();
                 return resizedImage;
             }
         
         private static Color computeAverage (BufferedImage bi) {
             long rSum = 0;
             long gSum = 0;
             long bSum = 0;
             for (int i = 0; i < bi.getWidth(); i++) {
                 for (int j = 0; j < bi.getHeight(); j++) {
                     Color c = new Color (bi.getRGB(i, j));
                     rSum += c.getRed();
                     gSum += c.getGreen();
                     bSum += c.getBlue();
                 }
             }
             int totalPixels = bi.getWidth() * bi.getHeight();
             return new Color((int) (rSum / totalPixels), (int) (gSum / totalPixels), (int) (bSum / totalPixels));
         }
 }

 */
