
//  ProfileViewController.swift
//  Image-modification-toolkit
//
//  Created by McKelvey Student on 11/29/23.
import UIKit
import Firebase
//import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func viewDidLoad() {
           super.viewDidLoad()
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profilePictureTapped))
           profilePicture.addGestureRecognizer(tapGesture)
           profilePicture.isUserInteractionEnabled = true

           fetchUserName()
       }

       @objc func profilePictureTapped() {
           showImagePicker()
       }

       func fetchUserName() {
           guard let userId = Auth.auth().currentUser?.uid else {
               print("User not logged in.")
               return
           }

           let db = Firestore.firestore()
           let usersCollection = db.collection("users")

           usersCollection.document(userId).getDocument { (document, error) in
               if let document = document, document.exists {
                   if let userName = document["username"] as? String {
                       self.nameLabel.text = userName
                   } else {
                       print("User name not found in document.")
                   }
               } else {
                   print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
               }
           }
       }

    func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profilePicture.image = pickedImage
            //uploadImageToFirebase(image: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }

//    func uploadImageToFirebase(image: UIImage) {
//        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
//            print("Failed to convert image to data.")
//            return
//        }
//
////        let storageRef = Storage.storage().reference().child("profile_images").child(UUID().uuidString)
////        let metadata = StorageMetadata()
//      //  metadata.contentType = "image/jpeg"
//
//    }
}
