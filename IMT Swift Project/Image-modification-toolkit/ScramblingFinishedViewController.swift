//
//  ScramblingFinishedViewController.swift
//  Image-modification-toolkit
//
//  Created by McKelvey Student on 11/15/23.
//
import Foundation
import Firebase
import FirebaseStorage
import UIKit

class ScramblingFinishedViewController: UIViewController {
    var scramblingPlaceholderAfter: UIImage = UIImage(named: "scrambledplaceholder")!
    var displayImage: UIImage?
    var codeString: String = ""
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var downloadButton: UIButton!
    
    @IBOutlet weak var editedImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        editedImage.image = displayImage
        codeField.text = codeString
       
    }
    @IBAction func downloadButtonClicked(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(displayImage!, nil, nil, nil)
    }
    @IBAction func saveToCloud(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid, let unscrambledResult = displayImage else {
            return
        }
        
        let storageRef = FirebaseStorage.Storage.storage().reference()
        let database = Firestore.firestore()
        let imageUUID = UUID().uuidString
        let userImagesRef = storageRef.child("user_images/\(uid)/\(imageUUID).jpg")
        if let imageData = unscrambledResult.jpegData(compressionQuality: 0.8) {
            userImagesRef.putData(imageData, metadata: nil) { (_, error) in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                }
                userImagesRef.downloadURL { (url, error) in
                    if let downloadURL = url?.absoluteString {
                        self.saveImageURLToFirestore(downloadURL: downloadURL, imageID: imageUUID)
                    } else {
                        print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                }
            }
        }
    }

    func saveImageURLToFirestore(downloadURL: String, imageID: String) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        let databaseRef = Firestore.firestore().collection("images")
        let data: [String: Any] = [
            "userID": user.uid,
            "imageID": imageID,
            "downloadURL": downloadURL
        ]

        databaseRef.document(imageID).setData(data) { error in
            if let error = error {
                print("Error saving image URL to Firestore: \(error.localizedDescription)")
            } else {
                print("Image URL saved successfully to Firestore.")
            }
        }
    }

}
