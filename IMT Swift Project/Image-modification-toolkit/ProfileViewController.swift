
//  ProfileViewController.swift
//  Image-modification-toolkit
//
//  Created by McKelvey Student on 11/29/23.                                                                                                                                                                                                                                                                                         
//  ProfileViewController.swift
//  Image-modification-toolkit
//
//  Created by McKelvey Student on 11/29/23.
import UIKit
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var imageCache = NSCache<NSString, UIImage>()


    var images = [ImageModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfileImage()
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "theCell")
        tableView.rowHeight = 120
        tableView.separatorStyle = .none
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profilePictureTapped))
        profilePicture.addGestureRecognizer(tapGesture)
        profilePicture.isUserInteractionEnabled = true
        profilePicture.layer.cornerRadius = profilePicture.bounds.width / 2
        profilePicture.clipsToBounds = true
        fetchUserName()
        observeImages()
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
                    self.nameLabel.text = "@\(userName)"
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

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
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
        let imageUUID = UUID().uuidString
        let userImagesRef = storageRef.child("user_images/\(uid)/\(imageUUID).jpg")

        if let imageData = image.jpegData(compressionQuality: 0.8) {
            userImagesRef.putData(imageData, metadata: nil) { (_, error) in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                }
                userImagesRef.downloadURL { (url, error) in
                    if let downloadURL = url?.absoluteString {
                        self.saveImageDetailsToDatabase(downloadURL: downloadURL, imageUUID: imageUUID)
                    } else {
                        print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                }
            }
        }
    }

    func saveImageDetailsToDatabase(downloadURL: String, imageUUID: String) {
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


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "theCell", for: indexPath)

    for subview in cell.contentView.subviews {
        subview.removeFromSuperview()
    }

    let imageModel = images[indexPath.row]

    let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: cell.contentView.frame.width - 180, height: 90))
    imageView.image = imageModel.image
    //imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true

    cell.contentView.addSubview(imageView)

    // Create a delete button
    let deleteButton = UIButton(type: .system)
    deleteButton.frame = CGRect(x: 10, y: 10, width: 18, height: 18)
    deleteButton.setTitle("x", for: .normal)
    deleteButton.setTitleColor(.white, for: .normal)
    deleteButton.backgroundColor = .black
    deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
    deleteButton.tag = indexPath.row

    cell.contentView.addSubview(deleteButton)

    // Create a view button
    let viewButton = UIButton(type: .system)
    viewButton.frame = CGRect(x: 10, y: 28, width: 18, height: 18)
    viewButton.setTitle("+", for: .normal)
    viewButton.setTitleColor(.white, for: .normal)
    viewButton.backgroundColor = .black
    viewButton.addTarget(self, action: #selector(viewButtonTapped(_:)), for: .touchUpInside)
    viewButton.tag = indexPath.row

    cell.contentView.addSubview(viewButton)

    return cell
}



@objc func viewButtonTapped(_ sender: UIButton) {
    let selectedImage = images[sender.tag]
    showSavedImagesController(with: selectedImage)
}

func showSavedImagesController(with selectedImage: ImageModel) {
    print("View button tapped for image with UUID: \(selectedImage.imageUUID)")
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if let savedImagesController = storyboard.instantiateViewController(withIdentifier: "SavedImagesViewController") as? SavedImagesViewController {
        savedImagesController.selectedImageModel = selectedImage
        navigationController?.pushViewController(savedImagesController, animated: true)
    }
}
    @objc func deleteButtonTapped(_ sender: UIButton) {
        let imageToDelete = images[sender.tag]
        deleteImage(imageToDelete)
    }

    func deleteImage(_ imageModel: ImageModel) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let db = Firestore.firestore()

        db.collection("images").document(imageModel.imageUUID).delete { error in
            if let error = error {
                print("Error deleting image document: \(error.localizedDescription)")
                return
            }

            let storageRef = FirebaseStorage.Storage.storage().reference()
            let userImagesRef = storageRef.child("user_images/\(uid)/\(imageModel.imageUUID).jpg")

            userImagesRef.delete { error in
                if let error = error {
                    print("Error deleting image file: \(error.localizedDescription)")
                    return
                }

                if let index = self.images.firstIndex(where: { $0.imageUUID == imageModel.imageUUID }) {
                    self.images.remove(at: index)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }

                print("Image deleted successfully")
            }
        }
    }
    func loadProfileImage() {
            guard let uid = Auth.auth().currentUser?.uid else {
                print("User not logged in.")
                return
            }

            let db = Firestore.firestore()
            let profilePictureRef = db.collection("profile_pictures").document(uid)

            profilePictureRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let imageUUID = document["imageUUID"] as? String {
                        // Check if the image is already in the cache
                        if let cachedImage = self.imageCache.object(forKey: imageUUID as NSString) {
                            self.profilePicture.image = cachedImage
                        } else {
                            let storageRef = FirebaseStorage.Storage.storage().reference()
                            let userImagesRef = storageRef.child("user_images/\(uid)/\(imageUUID).jpg")

                            userImagesRef.downloadURL { (url, error) in
                                if let imageUrl = url {
                                    URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                                        if let data = data, let image = UIImage(data: data) {
                                            // Cache the downloaded image
                                            self.imageCache.setObject(image, forKey: imageUUID as NSString)
                                            DispatchQueue.main.async {
                                                self.profilePicture.image = image
                                            }
                                        }
                                    }.resume()
                                }
                            }
                        }
                    }
                }
            }
        }

        func observeImages() {
            guard let uid = Auth.auth().currentUser?.uid else {
                print("User not logged in.")
                return
            }

            let db = Firestore.firestore()
            let imagesCollection = db.collection("images").whereField("userID", isEqualTo: uid)

            imagesCollection.addSnapshotListener { (snapshot, error) in
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    if let error = error {
                        print("Error fetching images: \(error.localizedDescription)")
                    } else {
                        print("No images found")
                    }
                    return
                }

                for document in documents {
                    if let imageUUID = document["imageID"] as? String,
                       let encryptionCode = document["encryptionCode"] as? String,
                       let timestamp = document["timestamp"] as? String
                    {
                        let storageRef = FirebaseStorage.Storage.storage().reference()
                        let userImagesRef = storageRef.child("user_images/\(uid)/\(imageUUID).jpg")

                        userImagesRef.downloadURL { (url, error) in
                            if let imageUrl = url {
                                URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                                    if let data = data, let image = UIImage(data: data) {
                                        // Cache the downloaded image
                                        self.imageCache.setObject(image, forKey: imageUUID as NSString)
                                        let imageModel = ImageModel(image: image, encryptionCode: encryptionCode, timestamp: timestamp, imageUUID: imageUUID)
                                        self.images.append(imageModel)
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
                                    }
                                }.resume()
                            }
                        }
                    }
                }
            }
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedImage = images[indexPath.row]
        showSavedImagesController(with: selectedImage)
    }
}

struct ImageModel {
    let image: UIImage
    let encryptionCode: String
    let timestamp: String
    let imageUUID: String
}
