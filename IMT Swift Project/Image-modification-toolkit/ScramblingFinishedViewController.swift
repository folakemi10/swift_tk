//
//  ScramblingFinishedViewController.swift
//  Image-modification-toolkit
//
//  Created by McKelvey Student on 11/15/23.
//

import Foundation

import UIKit

class ScramblingFinishedViewController: UIViewController {
    var scramblingPlaceholderAfter: UIImage = UIImage(named: "scrambledplaceholder")!
    var displayImage: UIImage?
    var codeString: String = ""
    @IBOutlet weak var codeField: UITextField!
    
    @IBOutlet weak var editedImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        editedImage.image = displayImage
        codeField.text = codeString
       
    }
   
}
