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
import Firebase
import FirebaseStorage

class PuzzleInnerViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var secondsElapsed: Double = 0.0
    @IBOutlet weak var timeElapsed: UITextField!
    @IBOutlet weak var puzzleImage: UIImageView!
    let category = "Puzzle"
    
    @IBOutlet weak var originalImage: UIImageView!
    @IBOutlet weak var HighScore: UITextField!
    @IBOutlet weak var score: UITextField!
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
        fetchAndDisplayBestTime()
        puzzleImage.image = scrambledImage
        originalImage.image =  original
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
                let xCoordinate = targetPoint.x
                let yCoordinate = targetPoint.y
                
               
                
                let xImgCoord = Int((Int(xCoordinate) * dimension) / (Int(puzzleImage.frame.width)))
                let yImgCoord = Int((Int(yCoordinate) * dimension) / (Int(puzzleImage.frame.width)))
                
                if (modulo2 % 2 == 0) {
                    lastX = xImgCoord
                    lastY = yImgCoord
                }
                else {
                    let imc = ImageModificationClass(imageArg: scrambledImage!)
                    imc.setSafePrimeIndex(spIndex: safePrimeIndex)
                    imc.setMosaicPixelSize(pxSize: Int(puzzleImage.frame.width) / dimension)
                    imc.swapPixels(x1: lastX, y1: lastY, x2: xImgCoord, y2: yImgCoord)
                   // checkIfSolved(imc: imc)
                    scrambledImage = imc.getCurrentImage().uiImage
                    puzzleImage.image = scrambledImage
              
                }
                
                modulo2 += 1
            }
        }
        
    }
    func checkIfSolved(imc: ImageModificationClass) {
        print("here")
        if (imc.equivalent(inputimg: Image<RGBA<UInt8>> (uiImage: original!))) {
            print("here2")
            stopTimer()
            saveGameToFirestore(time: secondsElapsed)
            fetchAndDisplayBestTime()
            showAlert(message: "Congratulations! You completed the puzzle.")
          
            if (bestTime.truncatingRemainder(dividingBy: 60.0) < 9.99999) {
                HighScore.text = String(format: "\(Int(bestTime / 60.0)):0%.1f", bestTime.truncatingRemainder(dividingBy: 60.0))
            }
            else {
                HighScore.text = String(format: "\(Int(bestTime / 60.0)):%.1f", bestTime.truncatingRemainder(dividingBy: 60.0))
            }
            
        }
        else {
            let scambledImage = imc.getCurrentImage().uiImage
            originalImage.image = scambledImage
        }
    }
    
    func saveGameToFirestore(time: Double) {
            guard let user = Auth.auth().currentUser else {
                return
            }

            let db = Firestore.firestore()

        let query = db.collection("games").whereField("userID", isEqualTo: user.uid).whereField("game_name", isEqualTo: category )
            query.getDocuments { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                if let existingGameDoc = documents.first {
                    let existingTime = existingGameDoc.data()["time"] as? Double ?? 0.0
                    if time < existingTime {
                        existingGameDoc.reference.updateData(["time": time])
                        print("Updated existing game time.")
                    }
                } else {
                    let gameRef = db.collection("games").document()
                    let data: [String: Any] = [
                        "userID": user.uid,
                        "time": time,
                        "game_name": self.category
                    ]

                    gameRef.setData(data) { error in
                        if let error = error {
                            print("Error saving game to Firestore: \(error.localizedDescription)")
                        } else {
                            print("Game saved successfully to Firestore.")
                        }
                    }
                }
            }
        }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func fetchAndDisplayBestTime() {
        let db = Firestore.firestore()
        let query = db.collection("games").whereField("game_name", isEqualTo: self.category).order(by: "time", descending: false).limit(to: 1)
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents, let bestGameDoc = documents.first else {
                return
            }

            let bestTime = bestGameDoc.data()["time"] as? Double ?? 0.0
            self.HighScore.text = String(format: "%.1f", bestTime)
        }
    }

    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
   
}
