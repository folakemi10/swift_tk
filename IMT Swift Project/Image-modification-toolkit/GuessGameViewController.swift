//
//  GuessGameViewController.swift
//  Image-modification-toolkit
//
//  Created by Juncheng Yang on 11/7/23.
//

import UIKit

class GuessGameViewController: UIViewController {

    var selectedImageName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
   
    @IBAction func monarch(_ sender: Any) {
        selectedImageName = "monarch"
    }
    @IBAction func flower(_ sender: Any) {
        selectedImageName = "flowers"
    }
    @IBAction func starryNight(_ sender: Any) {
        selectedImageName = "starrynight"
    }
    @IBAction func dog(_ sender: Any) {
        selectedImageName = "dog"
    }
    @IBAction func monaLisa(_ sender: Any) {
        selectedImageName = "monalisa"
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == selectedImageName {
               if let destinationVC = segue.destination as? GuessIndividualViewController {
                   destinationVC.imageName = selectedImageName
               }
           }
       }

}
