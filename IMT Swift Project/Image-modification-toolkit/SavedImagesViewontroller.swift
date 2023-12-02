//
//  SavedImagesViewontroller.swift
//  Image-modification-toolkit
//
//  Created by McKelvey Student on 12/2/23.
//
import UIKit
import SwiftImage
import SwiftUI

class SavedImagesViewController: UIViewController {

    @IBOutlet weak var savedImage: UIImageView!
    @IBOutlet weak var dateSaved: UILabel!
    @IBOutlet weak var encryptionCodeLabel: UILabel!
    var selectedImageModel: ImageModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectedImageModel = selectedImageModel {
            savedImage.image = selectedImageModel.image
            dateSaved.text = selectedImageModel.timestamp
            encryptionCodeLabel.text = selectedImageModel.encryptionCode
        }
    }

    @IBAction func DownloadImge(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum( savedImage.image!, nil, nil, nil)
    }
    

}
