//
//  PuzzleInnerViewController.swift
//  Image-modification-toolkit
//
//  Created by McKelvey Student on 11/30/23.
//

import Foundation
import UIKit
import SwiftImage
import SwiftUI

class PuzzleInnerViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var bestTimeField: UITextField!
    var secondsElapsed: Double = 0.0
    @IBOutlet weak var timeElapsed: UITextField!
    @IBOutlet weak var puzzleImage: UIImageView!
    
    var scrambledImage: UIImage?
    var modulo2: Int = 0
    var dimension: Int = 0
    var bestTime: Double = 999999.99
    var original: UIImage?
    
    var lastX: Int = 0
    var safePrimeIndex: Int = 3
    var lastY: Int = 0
    
    var timer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        puzzleImage.image = scrambledImage

        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateStatus), userInfo: nil, repeats: true)
        
        timeElapsed.isUserInteractionEnabled = false
        
    }
    
    @objc func updateStatus () {
        secondsElapsed += 0.1
        if (secondsElapsed.truncatingRemainder(dividingBy: 60.0) < 9.99999) {
            timeElapsed.text = String(format: "\(Int(secondsElapsed / 60.0)):0%.1f", secondsElapsed.truncatingRemainder(dividingBy: 60.0))
        }
        else {
            timeElapsed.text = String(format: "\(Int(secondsElapsed / 60.0)):%.1f", secondsElapsed.truncatingRemainder(dividingBy: 60.0))
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let targetPoint = (touches.first)!.location(in: puzzleImage) as CGPoint
        
        if (targetPoint.x >= 0 && targetPoint.x <= puzzleImage.frame.width) {
            if (targetPoint.y >= 0 && targetPoint.y <= puzzleImage.frame.height) {
                var xCoordinate = targetPoint.x
                var yCoordinate = targetPoint.y
                
               
                
                var xImgCoord = Int((Int(xCoordinate) * dimension) / (Int(puzzleImage.frame.width)))
                var yImgCoord = Int((Int(yCoordinate) * dimension) / (Int(puzzleImage.frame.width)))
                
                if (modulo2 % 2 == 0) {
                    lastX = xImgCoord
                    lastY = yImgCoord
                }
                else {
                    var imc = ImageModificationClass(imageArg: scrambledImage!)
                    imc.setSafePrimeIndex(spIndex: safePrimeIndex)
                    imc.setMosaicPixelSize(pxSize: Int(puzzleImage.frame.width) / dimension)
                    imc.swapPixels(x1: lastX, y1: lastY, x2: xImgCoord, y2: yImgCoord)
                    scrambledImage = imc.getCurrentImage().uiImage
                    puzzleImage.image = scrambledImage
                    
                    //checkIfSolved(imc: imc)
                    
                }
                
                

                print("(x, y) = (\(xImgCoord), \(yImgCoord)))")
                
                modulo2 += 1
            }
        }
        
        
        
        

    }
    func checkIfSolved(imc: ImageModificationClass) {
        if (imc.equivalent(inputimg: Image<RGBA<UInt8>> (uiImage: original!))) {
            stopTimer()
            if (secondsElapsed < bestTime) {
                bestTime = secondsElapsed
            }
            
            if (bestTime.truncatingRemainder(dividingBy: 60.0) < 9.99999) {
                bestTimeField.text = String(format: "\(Int(bestTime / 60.0)):0%.1f", bestTime.truncatingRemainder(dividingBy: 60.0))
            }
            else {
                bestTimeField.text = String(format: "\(Int(bestTime / 60.0)):%.1f", bestTime.truncatingRemainder(dividingBy: 60.0))
            }
            
        }
    }
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
   
}
