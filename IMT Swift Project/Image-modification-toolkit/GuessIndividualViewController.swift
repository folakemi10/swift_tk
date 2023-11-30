//
//  GuessIndividualViewController.swift
//  Image-modification-toolkit
//
//  Created by McKelvey Student on 11/30/23.
import Foundation
import UIKit
import SwiftImage
import SwiftUI
import Firebase

class GuessIndividualViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var YourTime: UITextField!
    @IBOutlet weak var bestTime: UITextField!
    var secondsElapsed: Double = 0.0
    @IBOutlet weak var puzzleImage: UIImageView!
    @IBOutlet weak var guessField: UITextField!
    
    var imageName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let imageName = imageName {
            puzzleImage.image = UIImage(named: imageName)
            fetchAndDisplayBestTime()
        }
        let timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateStatus), userInfo: nil, repeats: true)
        YourTime.isUserInteractionEnabled = false
        
    }
    
    @objc func updateStatus () {
        secondsElapsed += 0.1
        if (secondsElapsed.truncatingRemainder(dividingBy: 60.0) < 9.99999) {
            YourTime.text = String(format: "\(Int(secondsElapsed / 60.0)):0%.1f", secondsElapsed.truncatingRemainder(dividingBy: 60.0))
        }
        else {
            YourTime.text = String(format: "\(Int(secondsElapsed / 60.0)):%.1f", secondsElapsed.truncatingRemainder(dividingBy: 60.0))
        }
        
    }
    
    @IBAction func Guess(_ sender: Any) {
           if guessField.text?.lowercased() == imageName?.lowercased() {
               showAlert(message: "Nice job!")
               saveGameToFirestore(time: secondsElapsed)
               fetchAndDisplayBestTime()
           }
       }

    func saveGameToFirestore(time: Double) {
           guard let user = Auth.auth().currentUser else {
               return
           }

           let db = Firestore.firestore()

           let query = db.collection("games").whereField("userID", isEqualTo: user.uid).whereField("game_name", isEqualTo: imageName ?? "")
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
                       "game_name": self.imageName ?? ""
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

       func fetchAndDisplayBestTime() {
           
           let db = Firestore.firestore()
           let query = db.collection("games").whereField("game_name", isEqualTo: imageName ?? "").order(by: "time", descending: false).limit(to: 1)
           query.getDocuments { (snapshot, error) in
               guard let documents = snapshot?.documents, let bestGameDoc = documents.first else {
                   print("Error fetching best time: \(error?.localizedDescription ?? "Unknown error")")
                   return
               }

               let bestTime = bestGameDoc.data()["time"] as? Double ?? 0.0
               self.bestTime.text = String(format: "%.1f", bestTime)
           }
       }
   
       private func showAlert(message: String) {
           let alert = UIAlertController(title: "Win", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           present(alert, animated: true, completion: nil)
       }
   }
