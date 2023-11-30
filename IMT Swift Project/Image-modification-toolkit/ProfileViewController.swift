
//  ProfileViewController.swift
//  Image-modification-toolkit
//
//  Created by McKelvey Student on 11/29/23.
import UIKit
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profilePicture: UIImageView!
//    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profilePictureTapped))
        profilePicture.addGestureRecognizer(tapGesture)
        profilePicture.isUserInteractionEnabled = true
        
        fetchUserName()
        loadProfileImage()
       // observeImages()
    }
    
    @objc func profilePictureTapped() {
        showImagePicker()
    }
    
    @IBAction func editButton(_ sender: Any) {
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
            uploadImageToFirebase(image: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func uploadImageToFirebase(image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let storageRef = FirebaseStorage.Storage.storage().reference()
        let imageUUID = UUID().uuidString // Generate a UUID for the image
        let userImagesRef = storageRef.child("user_images/\(uid)/\(imageUUID).jpg")
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            userImagesRef.putData(imageData, metadata: nil) { (_, error) in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                }
                userImagesRef.downloadURL { (url, error) in
                    if let downloadURL = url?.absoluteString {
                        self.saveImageURLToDatabase(downloadURL: downloadURL, imageUUID: imageUUID)
                    } else {
                        print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                }
            }
        }
    }
    
    func saveImageURLToDatabase(downloadURL: String, imageUUID: String) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let db = Firestore.firestore()
        
        let profilePictureRef = db.collection("profile_pictures").document(user.uid)
        
        profilePictureRef.getDocument { (document, error) in
            if let document = document, document.exists {
                profilePictureRef.updateData(["profile_picture": downloadURL, "imageUUID": imageUUID]) { error in
                    if let error = error {
                        print("Error updating profile picture document: \(error.localizedDescription)")
                    } else {
                        print("Profile picture edited")
                    }
                }
            } else {
                let data: [String: Any] = [
                    "userID": user.uid,
                    "profile_picture": downloadURL,
                    "imageUUID": imageUUID
                ]
                
                db.collection("profile_pictures").document(user.uid).setData(data) { error in
                    if let error = error {
                        print("Error creating profile picture document: \(error.localizedDescription)")
                    } else {
                        print("Profile picture created")
                    }
                }
            }
        }
    }
    
    func loadProfileImage() {
        print("in here load data")
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }
        
        let db = Firestore.firestore()
        let profilePictureRef = db.collection("profile_pictures").document(uid)
        
        profilePictureRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let imageUUID = document["imageUUID"] as? String {
                    let storageRef = FirebaseStorage.Storage.storage().reference()
                    let userImagesRef = storageRef.child("user_images/\(uid)/\(imageUUID).jpg")
                    
                    userImagesRef.downloadURL { (url, error) in
                        if let imageUrl = url {
                            URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                                if let data = data, let image = UIImage(data: data) {
                                    DispatchQueue.main.async {
                                        self.profilePicture.image = image
                                        print("in here load data2")
                                    }
                                }
                            }.resume()
                        }
                    }
                }
            }
        }
    }
   
//    var imageUUIDs = [String]()
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return imageUUIDs.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "YourCellIdentifier", for: indexPath)
//
//        cell.textLabel?.text = imageUUIDs[indexPath.row]
//        cell.backgroundColor = . blue
//        return cell
//    }
//
//    func observeImages() {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            print("User not logged in.")
//            return
//        }
//
//        let db = Firestore.firestore()
//        let imagesCollection = db.collection("images")
//
//        imagesCollection.whereField("userID", isEqualTo: userId).addSnapshotListener { (snapshot, error) in
//            guard let documents = snapshot?.documents else {
//                print("Error fetching images: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//
//            var fetchedImageUUIDs = [String]()
//            for document in documents {
//                if let imageUUID = document["imageID"] as? String {
//                    fetchedImageUUIDs.append(imageUUID)
//                }
//            }
//
//            self.imageUUIDs = fetchedImageUUIDs
//
//            self.tableView.reloadData()
//        }
//    }
}

