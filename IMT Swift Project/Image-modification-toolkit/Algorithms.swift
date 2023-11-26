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
    private var safePrimeIndex: Int = 3
    private var safePrimes: [Int] = [5, 7, 11, 23, 47, 59, 83, 107, 167, 179, 227, 263, 347, 359, 383, 467, 479, 503, 563, 587, 719, 839, 863, 887, 983, 1019, 1187, 1283, 1307, 1319, 1367, 1439, 1487, 1523, 1619, 1823, 1907, 2027, 2039, 2063, 2099, 2207, 2447, 2459, 2579, 2819, 2879, 2903, 2963, 2999, 3023, 3119, 3167, 3203, 3467, 3623, 3779, 3803, 3863, 3947, 4007, 4079, 4127, 4139, 4259, 4283, 4547, 4679, 4703, 4787, 4799, 4919]
    
    public func setSafePrimeIndex (spIndex: Int) {
        safePrime = safePrimes[spIndex]
        safePrimeIndex = spIndex
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
        for _ in 0..<k {
            value *= base
            value %= safePrime
        }
        return value
    }

    
    private func discreteLogarithm(_ a: Int, _ b: Int, _ m: Int) -> Int {
        let n = Int(Double(m).squareRoot()) + 1
        var an = 1
        for _ in 0..<n {
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
                let ans = value[cur] * n - i
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
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origRow.append(m.getPixel(xCoord:j, yCoord: y))
            }
            let scrambledRow = mosaicEncrypt(original: origRow, pr: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: j, y: y, inputimg: scrambledRow[j])
            }
        }
        scrambled = m.getMosaic()
        return scrambled
    }
    
    private func mosaicScramble2 (original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origCol.append(m.getPixel(xCoord:x, yCoord: j))
            }
            let scrambledCol = mosaicEncrypt(original: origCol, pr: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: x, y: j, inputimg: scrambledCol[j])
            }
        }
        scrambled = m.getMosaic()
        return scrambled
    }
    
    private func mosaicScrambleD1(original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                let modifiedY = (y + prToThe(base: pr1, k: j)) % (safePrime - 1)
                origRow.append(m.getPixel(xCoord:j, yCoord: modifiedY))
            }
            let scrambledRow = mosaicEncrypt(original: origRow, pr: pr2)
            for j in 0..<(safePrime-1) {
                let modifiedY = (y + prToThe(base: pr1, k: j)) % (safePrime - 1)
                m.setPixel(x: j, y: modifiedY, inputimg: scrambledRow[j])
            }
        }
        scrambled = m.getMosaic()
        return scrambled
    }
    
    private func mosaicScrambleD2(original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                let modifiedX = (x + prToThe(base: pr1, k: j)) % (safePrime - 1)
                origCol.append(m.getPixel(xCoord:modifiedX, yCoord: j))
            }
            let scrambledCol = mosaicEncrypt(original: origCol, pr: pr2)
            for j in 0..<(safePrime-1) {
                let modifiedX = (x + prToThe(base: pr1, k: j)) % (safePrime - 1)
                m.setPixel(x: modifiedX, y: j, inputimg: scrambledCol[j])
            }
        }
        scrambled = m.getMosaic()
        return scrambled
    }
    
    private func mosaicUnscrambleRows (original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origCol.append(m.getPixel(xCoord:x, yCoord: j))
            }
            let unscrambledCol = mosaicDecrypt(original: origCol, pr: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: x, y: j, inputimg: unscrambledCol[j])
            }
        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    private func mosaicUnscrambleCols (original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origRow.append(m.getPixel(xCoord:j, yCoord: y))
            }
            let unscrambledRow = mosaicDecrypt(original: origRow, pr: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: j, y: y, inputimg: unscrambledRow[j])
            }
        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    private func mosaicUnscrambleD1 (original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                let modifiedY = (y + prToThe(base: pr1, k: j)) % (safePrime - 1)
                origRow.append(m.getPixel(xCoord:j, yCoord: modifiedY))
            }
            let unscrambledRow = mosaicDecrypt(original: origRow, pr: pr2)
            for j in 0..<(safePrime-1) {
                let modifiedY = (y + prToThe(base: pr1, k: j)) % (safePrime - 1)
                m.setPixel(x: j, y: modifiedY, inputimg: unscrambledRow[j])
            }
        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    private func mosaicUnscrambleD2 (original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                let modifiedX = (x + prToThe(base: pr1, k: j)) % (safePrime - 1)
                origCol.append(m.getPixel(xCoord:modifiedX, yCoord: j))
            }
            let unscrambledCol = mosaicDecrypt(original: origCol, pr: pr2)
            for j in 0..<(safePrime-1) {
                let modifiedX = (x + prToThe(base: pr1, k: j)) % (safePrime - 1)
                m.setPixel(x: modifiedX, y: j, inputimg: unscrambledCol[j])
            }
        }
        unscrambled = m.getMosaic()
        return unscrambled
    }

    private func funnyMosaicScramble(original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origRow.append(m.getPixel(xCoord:j, yCoord: y))
            }
            let scrambledRow = funnyMosaicEncrypt(original: origRow, a: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: j, y: y, inputimg: scrambledRow[j])
            }
        }
        scrambled = m.getMosaic()
        return scrambled
    }
    
    private func funnyMosaicScramble2 (original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origCol.append(m.getPixel(xCoord:x, yCoord: j))
            }
            let scrambledCol = funnyMosaicEncrypt (original: origCol, a: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: x, y: j, inputimg: scrambledCol[j])
            }
        }
        scrambled = m.getMosaic()
        return scrambled
    }

    private func funnyMosaicScrambleD1(original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                let modifiedY = (y + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                origRow.append(m.getPixel(xCoord:j, yCoord: modifiedY))
            }
            let scrambledRow = funnyMosaicEncrypt(original: origRow, a: pr2)
            for j in 0..<(safePrime-1) {
                let modifiedY = (y + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                m.setPixel(x: j, y: modifiedY, inputimg: scrambledRow[j])
            }
        }
        scrambled = m.getMosaic()
        return scrambled
    }

    private func funnyMosaicScrambleD2(original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var scrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: scrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                let modifiedX = (x + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                origCol.append(m.getPixel(xCoord:modifiedX, yCoord: j))
            }
            let scrambledCol = funnyMosaicEncrypt(original: origCol, a: pr2)
            for j in 0..<(safePrime-1) {
                let modifiedX = (x + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                m.setPixel(x: modifiedX, y: j, inputimg: scrambledCol[j])
            }
        }
        scrambled = m.getMosaic()
        return scrambled
    }

    private func funnyMosaicUnscrambleRows (original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origCol.append(m.getPixel(xCoord:x, yCoord: j))
            }
            let unscrambledCol = funnyMosaicDecrypt(original: origCol, a: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: x, y: j, inputimg: unscrambledCol[j])
            }
        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    private func funnyMosaicUnscrambleCols (original: Image<RGBA<UInt8>>, pr: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                origRow.append(m.getPixel(xCoord:j, yCoord: y))
            }
            let unscrambledRow = funnyMosaicDecrypt(original: origRow, a: pr)
            for j in 0..<(safePrime-1) {
                m.setPixel(x: j, y: y, inputimg: unscrambledRow[j])
            }
        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    private func funnyMosaicUnscrambleD1 (original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for y in 0..<(safePrime-1) {
            var origRow: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                let modifiedY = (y + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                origRow.append(m.getPixel(xCoord:j, yCoord: modifiedY))
            }
            let unscrambledRow = funnyMosaicDecrypt(original: origRow, a: pr2)
            for j in 0..<(safePrime-1) {
                let modifiedY = (y + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                m.setPixel(x: j, y: modifiedY, inputimg: unscrambledRow[j])
            }
        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    private func funnyMosaicUnscrambleD2 (original: Image<RGBA<UInt8>>, pr1: Int, pr2: Int) -> Image<RGBA<UInt8>>{
        var unscrambled: Image<RGBA<UInt8>> = original
        let m = Mosaic (spd: safePrime - 1, ps: pixelSize, inputimg: unscrambled)
        for x in 0..<(safePrime-1) {
            var origCol: [Image<RGBA<UInt8>>] = []
            for j in 0..<(safePrime-1) {
                let modifiedX = (x + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                origCol.append(m.getPixel(xCoord:modifiedX, yCoord: j))
            }
            let unscrambledCol = funnyMosaicDecrypt(original: origCol, a: pr2)
            for j in 0..<(safePrime-1) {
                let modifiedX = (x + prToThe(base: j+1, k: pr1)) % (safePrime - 1)
                m.setPixel(x: modifiedX, y: j, inputimg: unscrambledCol[j])
            }
        }
        unscrambled = m.getMosaic()
        return unscrambled
    }
    
    //now, onto layer 4 (the surface level) of the encryption/decryption functions
    
    public func enhancedMosaicEncrypt () {
        let width = (safePrime - 1) * pixelSize
        let height = (safePrime - 1) * pixelSize
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
        let scrambledImage = mosaicScramble(original: image, pr: proot1)
        let scrambledImage2 = mosaicScramble2(original: scrambledImage, pr: proot2)
        let scrambledImage3 = mosaicScrambleD1(original: scrambledImage2, pr1: proot3, pr2: proot4)
        let scrambledImage4 = mosaicScrambleD2(original: scrambledImage3, pr1: proot5, pr2: proot6)
        let scrambledImage5 = funnyMosaicScramble(original: scrambledImage4, pr: a1)
        let scrambledImage6 = funnyMosaicScramble2 (original: scrambledImage5, pr: a2)
        let scrambledImage7 = funnyMosaicScrambleD1 (original: scrambledImage6, pr1: a3, pr2: a4)
        let scrambledImage8 = funnyMosaicScrambleD2 (original: scrambledImage7, pr1: a5, pr2: a6)
        image = scrambledImage8
        secretCode = String(proot1) + " " + String(proot2) + " " + String(proot3) + " " + String(proot4) + " " + String(proot5) + " " + String(proot6) + " " + String(a1) + " " + String(a2) + " " + String(a3) + " " + String(a4) + " " + String(a5) + " " + String(a6) + " " + String(safePrimeIndex)
        
    }
    
    public func enhancedMosaicDecrypt (pr1: Int, pr2: Int, pr3: Int, pr4: Int, pr5: Int, pr6: Int, a1: Int, a2: Int, a3: Int, a4: Int, a5: Int, a6: Int, sPrime: Int) {
        safePrime = sPrime
        let width = (safePrime - 1) * pixelSize
        let height = (safePrime - 1) * pixelSize
        image = resizeImage (orig: rawImage, targetWidth: width, targetHeight: height)
        
        let unscrambledImage1 = funnyMosaicUnscrambleD2 (original: image, pr1: a5, pr2: a6)
        let unscrambledImage2 = funnyMosaicUnscrambleD1 (original: unscrambledImage1, pr1: a3, pr2: a4)
        let unscrambledImage3 = funnyMosaicUnscrambleRows (original: unscrambledImage2, pr: a2)
        let unscrambledImage4 = funnyMosaicUnscrambleCols (original: unscrambledImage3, pr: a1)
        
        let unscrambledImage5 = mosaicUnscrambleD2 (original: unscrambledImage4, pr1: pr5, pr2: pr6)
        let unscrambledImage6 = mosaicUnscrambleD1 (original: unscrambledImage5, pr1: pr3, pr2: pr4)
        let unscrambledImage7 = mosaicUnscrambleRows (original: unscrambledImage6, pr: pr2)
        let unscrambledImage8 = mosaicUnscrambleCols (original: unscrambledImage7, pr: pr1)
        
        image = unscrambledImage8
    }
}

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
                let newRGB = inputimg[i % pixelSize, j % pixelSize]
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
