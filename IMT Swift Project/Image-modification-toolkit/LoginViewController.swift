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

               checkUsernameAndPassword(username: username, password: password)
           }

   private func checkUsernameAndPassword(username: String, password: String) {
       let db = Firestore.firestore()
       let usersRef = db.collection("users")

       usersRef.whereField("username", isEqualTo: username).getDocuments { (snapshot, error) in
           if let error = error {
               print("Error checking username: \(error.localizedDescription)")
               self.showAlert(message: "Error checking username.")
           } else if let snapshot = snapshot, !snapshot.isEmpty {
              
               _ = snapshot.documents.first!

               if let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeViewController") {
                   if let navigationController = self.navigationController {
                       print("Login successful.")
                       navigationController.setViewControllers([homeViewController], animated: true)
                   }
               }
           } else {
               // Username does not exist
               self.showAlert(message: "Username does not exist.")
           }
       }
   }


    override func viewDidLoad() {
           super.viewDidLoad()
           // Do any additional setup after loading the view.
       }
    private func showAlert(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
}
