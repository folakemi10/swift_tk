//import Foundation
//import Firebase
//import FirebaseStorage
//import UIKit
//
//class UnscramblingFinishedViewController: UIViewController {
//    var unscramblingPlaceholderAfter: UIImage = UIImage(named: "normalplaceholder")!
//    @IBOutlet weak var editedImage: UIImageView!
//    var unscrambledResult: UIImage?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        editedImage.image = unscrambledResult
//
//    }
//
//    @IBAction func downloadClicked(_ sender: Any) {
//        UIImageWriteToSavedPhotosAlbum (unscrambledResult!, nil, nil, nil)
//    }
//
//    @IBAction func saveToProfile(_ sender: Any) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let imageID = NSUUID().uuidString.lowercased()
//
//        let storageRef = FirebaseStorage.Storage.storage().reference()
//
//        let userImagesRef = storageRef.child("user_images/\(uid)/\(imageID).jpg")
//
//        if let imageData = unscrambledResult?.jpegData(compressionQuality: 0.8) {
//            userImagesRef.putData(imageData, metadata: nil) { (metadata, error) in
//                guard let metadata = metadata else {
//                    print("Error uploading image: \(error?.localizedDescription ?? "Unknown error")")
//                    return
//                }
//
//
//                print("Image uploaded successfully. Download URL: \(metadata.downloadURL?.absoluteString ?? "")")
//
//                self.saveImageURLToDatabase(downloadURL: metadata.downloadURL?.absoluteString ?? "")
//            }
//        }
//    }
//
//
//    func saveImageURLToDatabase(downloadURL: String) {
//        guard let user = Auth.auth().currentUser else {
//            // Handle the case where the user is not authenticated
//            return
//        }
//
//        // Reference to the Firebase Realtime Database
//        let databaseRef = Database.database().reference()
//
//        // Reference to the user's specific directory (you can customize this as needed)
//        let userImagesRef = databaseRef.child("user_images/\(user.uid)")
//
//        // Generate a unique identifier for the image
//        let imageID = NSUUID().uuidString.lowercased()
//
//        // Save the image URL to the database
//        userImagesRef.child(imageID).setValue(downloadURL)
//    }
//}
//https://www.youtube.com/watch?v=YgjYVbg1oiA
