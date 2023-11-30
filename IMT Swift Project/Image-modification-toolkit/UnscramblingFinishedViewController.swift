import Foundation
import Firebase
import FirebaseStorage
import UIKit

class UnscramblingFinishedViewController: UIViewController {
    var unscramblingPlaceholderAfter: UIImage = UIImage(named: "normalplaceholder")!
    @IBOutlet weak var editedImage: UIImageView!
    var unscrambledResult: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editedImage.image = unscrambledResult
        
    }
    
    @IBAction func downloadClicked(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum (unscrambledResult!, nil, nil, nil)
    }

    @IBAction func saveToCloud(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid, let unscrambledResult = unscrambledResult else {
            return
        }

        let storageRef = FirebaseStorage.Storage.storage().reference()
       
        let imageUUID = UUID().uuidString // Generate a UUID for the image
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
