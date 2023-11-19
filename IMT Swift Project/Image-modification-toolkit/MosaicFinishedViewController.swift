//
//  MosaicFinishedViewController.swift
//  Image-modification-toolkit
//
//  Created by McKelvey Student on 11/15/23.
//

import Foundation

import UIKit

class MosaicFinishedViewController: UIViewController {
    var mosaicPlaceholderAfter: UIImage = UIImage(named: "emojifiedplaceholder")!

   
    @IBOutlet weak var editedImage: UIImageView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
       
        editedImage.image = mosaicPlaceholderAfter
       
    }
   
}
