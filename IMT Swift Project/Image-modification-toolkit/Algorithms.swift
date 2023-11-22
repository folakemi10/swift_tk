//
//  Algorithms.swift
//  Image-modification-toolkit
//
//  Created by Luke Zhang on 11/15/23.
//

import Foundation

import SwiftImage

class ImageModificationClass{
    var image:Image<RGBA<UInt8>>? = nil // TODO: Initialize Images? May not be necessary
    var rawImage:Image<RGBA<UInt8>>? = nil
    private var tempRoots: [Int] = []
    private var pixelSize: Int = 0
    private var tempA: [Int] = []
    private var safePrime: Int = 0
    enum Exception: Error {
        case cannotReadFile
    }
    public func getSafePrime() -> Int {
        return safePrime
    }
    public func tempRootArray() -> [Int]{
        return tempRoots
    }
    public func enhancedTempRootArray() -> [Int]{
        return tempRoots + tempA
    }
    private var safePrimes: [Int] = [5, 7, 11, 23, 47, 59, 83, 107, 167, 179, 227, 263, 347, 359, 383, 467, 479, 503, 563, 587, 719, 839, 863, 887, 983, 1019, 1187, 1283, 1307, 1319, 1367, 1439, 1487, 1523, 1619, 1823, 1907, 2027, 2039, 2063, 2099, 2207, 2447, 2459, 2579, 2819, 2879, 2903, 2963, 2999, 3023, 3119, 3167, 3203, 3467, 3623, 3779, 3803, 3863, 3947, 4007, 4079, 4127, 4139, 4259, 4283, 4547, 4679, 4703, 4787, 4799, 4919]
    public func setSafePrimeIndex (spIndex: Int) {
        safePrime = safePrimes[spIndex]
    }
    public func setMosaicPixelSize (pxSize: Int) {
        pixelSize = pxSize
    }
    private var approxImages: [Image<RGBA<UInt8>>] = []
    // TODO: Check if Any is correct initalizer
    // Original Java:
    // private ArrayList<BufferedImage> approxImages = new ArrayList<BufferedImage>();
    
    public func getApproxImages() -> [Image<RGBA<UInt8>>] {
        return approxImages
    }
    public func setApproxImages (directoryName: String, size: Int) throws {
        for file in try Folder(path: directoryName).files {
            guard let image = Image<RGBA<UInt8>>(named: file.name)
            else {return}
            let newImage = image.resizedTo(width:size, height: size)
            approxImages.append(newImage)
        }
    }
    private func computeAverage (image:Image<RGBA<UInt8>>) -> RGBA<UInt8> {
        var rSum: Int = 0, gSum: Int = 0, bSum: Int = 0
        for i in 0..<image.width {
            for j in 0..<image.height {
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
        // read image TODO: Check reading image
        // Currently assuming front end will read image and display it first, which means it can be fed to class after initializing as SwiftImage
        guard var image = rawImage?.resizedTo(width: width, height: height)
        else {
            print("Error, could not find rawImage")
            throw Exception.cannotReadFile
        }
        for x in 0..<width {
            for y in 0..<height {
                let slice: ImageSlice<RGBA<UInt8>> = image[x * emojiSize..<x * emojiSize + emojiSize, y * emojiSize..<y * emojiSize + emojiSize]
                let sub = Image<RGBA<UInt8>>(slice)
                let inputColor = computeAverage(image: sub)
                let index = determineClosestIndex(input: inputColor)
                let replace = approxImages[index]
                for i in x * emojiSize ..< (x+1) * emojiSize {
                    for j in y * emojiSize ..< (y+1) * emojiSize {
                        let newRGB = replace[i % emojiSize, j % emojiSize]
                        image[i, j] = newRGB
                    }
                }
            }
        }
        print("Image emojified with " + width + " emojis by " + height + " emojis. ")
//        imageView.image = image.uiImage
        
        return
    }
}
/*
     
           
                    for (int i = x*emojiSize; i < (x+1)*emojiSize; i++) {
                       for (int j = y*emojiSize; j < (y+1)*emojiSize; j++) {
                           int newRGB = replace.getRGB(i % emojiSize, j % emojiSize);
                           image.setRGB(i, j, newRGB);
          
                           
                       }
                    }
                    
                }
            }
            System.out.println("Image emojified with " + width + " emojis by " + height + " emojis. ");
           ImageIO.write(image, "png", f);
           System.out.println("Writing complete.");
            
     }
     
     
     
     private String fileName;
     public ImageModificationClass (String fn) {
         fileName = fn;
        
     }
     
     public ImageModificationClass (BufferedImage im) {
         rawImage = im;
        
     }
     
     public BufferedImage getImage () {
         return image;
     }
     
     
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
           //scramble each row
           for (int y = 0; y < safePrime - 1; y++) {
                ArrayList<BufferedImage> origRow = new ArrayList<BufferedImage>();
               
               for (int j = 0; j < safePrime - 1; j++) {
                   BufferedImage c = m.getPixel(j, y);
                   origRow.add(c);
               }

               for (BufferedImage bi : origRow) {
               }
               
               System.out.println();
               
               //line #1
               ArrayList<BufferedImage> scrambledRow = funnyMosaicEncrypt (origRow, pr);
               
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
