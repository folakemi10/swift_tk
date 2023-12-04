//
//  LoginViewController.swift
//  Image-modification-toolkit
//
//  Created by McKelvey Student on 11/14/23.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text, !username.isEmpty,
                     let password = passwordTextField.text, !password.isEmpty else {
                   showAlert(message: "Please enter a valid username and password.")
                   return
               }

               checkUsernameAndPassword(email: username, password: password)
           }

    private func checkUsernameAndPassword(email: String, password: String) {
        let db = Firestore.firestore()
        _ = db.collection("users")
        
        Auth.auth().signIn(withEmail: email, password: password){ authResult, error in
            if let error = error {
                print("Error login in user: \(error.localizedDescription)")
                self.showAlert(message: "Incorrect email or password")
            } else {
                
                print("User logged in successfully!")
                
                if let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeViewController") {
                    if let navigationController = self.navigationController {
                        print("Login successful.")
                        navigationController.setViewControllers([homeViewController], animated: true)
                    }
                }
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
