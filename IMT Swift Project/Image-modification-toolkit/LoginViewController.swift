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
    
    @IBOutlet weak var emailTextField: UITextField!
  
    @IBAction func login(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
                      let password = passwordTextField.text, !password.isEmpty else {
                
                    showAlert(message: "Please enter a valid email and password.")
                    return
                }

                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                       
                        print("Error registering user: \(error.localizedDescription)")
                        self.showAlert(message: "Error registering user: \(error.localizedDescription)")
                    } else {
                        
                        print("User registered successfully!")
                        
                         self.performSegue(withIdentifier: "Register", sender: self)
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
