//
//  Image-modification-toolkit
//
//  Created by McKelvey Student on 11/14/23.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    

    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
  
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBAction func SignUp(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
                    let password = passwordTextField.text, !password.isEmpty,
                    let username = usernameTextField.text, !username.isEmpty else {

                  showAlert(message: "Please enter a valid email, password, and username.")
                  return
              }
       
        
        checkUsernameExistsForSignup(username: username) { exists in
            if exists {
             
                self.showAlert(message: "Username already exists. Please choose a different username.")
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        print("Error registering user: \(error.localizedDescription)")
                        self.showAlert(message: "Error registering user: \(error.localizedDescription)")
                    } else {
                        
                        print("User registered successfully!")
                        
                      
                        if let uid = Auth.auth().currentUser?.uid {
                            self.updateFirestoreWithUsernameAndUID(uid: uid, username: username)
                            if let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeViewController") {
                                if let navigationController = self.navigationController {
                                    navigationController.setViewControllers([homeViewController], animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
          }

    private func updateFirestoreWithUsernameAndUID(uid: String, username: String) {
           let db = Firestore.firestore()
           let userRef = db.collection("users").document(uid)
           userRef.setData(["username": username, "uid": uid])
    }
        
    private func checkUsernameExistsForSignup(username: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let usersRef = db.collection("users")

        usersRef.whereField("username", isEqualTo: username).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking username: \(error.localizedDescription)")
                completion(false)
            } else if let snapshot = snapshot, !snapshot.isEmpty {
                
                completion(true)
            } else {
              
                completion(false)
            }
        }
    }
    override func viewDidLoad() {
           super.viewDidLoad()
           passwordTextField.isSecureTextEntry = true
        
    }
    private func showAlert(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
}

