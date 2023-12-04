//
//  MosaicViewController.swift
//  Image-modification-toolkit
//
//  Created by Juncheng Yang on 11/7/23.
//

import UIKit
import SwiftImage

class MosaicViewController: UIViewController {
    var size: Int = 10
    var height: Int = 600
    var width: Int = 600
    var mosaicImage: UIImage?
  
    @IBOutlet weak var imageBank: UIButton!
    @IBOutlet weak var uploadImage3: UIImageView!
    
    var imageSetNumber: Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let menuClosure = {(action: UIAction) in
            if (action.title == "image set 1") {
                self.imageSetNumber = 1
            }
            else if (action.title == "image set 2") {
                self.imageSetNumber = 2
            }
            else if (action.title == "image set 3") {
                self.imageSetNumber = 3
            }
            else if (action.title == "image set 4") {
                self.imageSetNumber = 4
            }
        }
        imageBank.menu = UIMenu(children: [
            UIAction(title: "image set 1", state: .on, handler: menuClosure),
            UIAction(title: "image set 2", handler: menuClosure),
            UIAction(title: "image set 3", handler: menuClosure),
            UIAction(title: "image set 4", handler: menuClosure)])
        
        imageBank.showsMenuAsPrimaryAction = true
        imageBank.changesSelectionAsPrimaryAction = true

        
    }
    var mosaicPlaceholderBefore: UIImage = UIImage(named: "normalplaceholder")!

       var mosaicPlaceholderAfter: UIImage = UIImage(named: "emojifiedplaceholder")!

    @IBOutlet weak var sizeValue: UITextField!
    @IBAction func sizeChanged(_ sender: Any) {
        if let a = sizeValue.text {
            if let b = Int(a) {
                size = b
            }
        }
    }
    @IBOutlet weak var heightValue: UITextField!
    @IBAction func heightChanged(_ sender: Any) {
        if let a = heightValue.text {
            if let b = Int(a) {
                height = b
            }
        }
    }
    @IBOutlet weak var widthValue: UITextField!
    @IBAction func widthChanged(_ sender: Any) {
        if let a = widthValue.text {
            if let b = Int(a) {
                width = b
            }
        }
    }

    @IBAction func chooseImage3(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

}

extension MosaicViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")]as? UIImage{
            uploadImage3.image = image
            
        }
//        uploadImage3.image = mosaicPlaceholderBefore;
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        uploadImage3.image = mosaicPlaceholderBefore;
        picker.dismiss(animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "finishedMosaic") {
            if let finished = segue.destination as? MosaicFinishedViewController {
                mosaicConvert()
                finished.mosaicResult = mosaicImage
            }
        }
    }
    
    func mosaicConvert() {
        let imc = ImageModificationClass(imageArg: uploadImage3.image!)
        imc.setApproxImages(bankIndex: imageSetNumber)
        imc.emojify(width: width, height: height, emojiSize: size)
        let mosaic:Image<RGBA<UInt8>> = imc.getCurrentImage()
        mosaicImage = mosaic.uiImage

    }
}

