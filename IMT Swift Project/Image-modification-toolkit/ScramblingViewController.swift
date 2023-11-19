//
//  ScramblingViewController.swift
//  Image-modification-toolkit
//
//  Created by Juncheng Yang on 11/7/23.
//

import UIKit

import SwiftImage

class ScramblingViewController: UIViewController {

    @IBOutlet weak var uploadImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var image = Image<RGBA<UInt8>>(named: "ImageName")!


        
        // Do any additional setup after loading the view.
    }
    
    
    var scramblingPlaceholderBefore: UIImage = UIImage(named: "normalplaceholder")!

       var scramblingPlaceholderAfter: UIImage = UIImage(named: "scrambledplaceholder")!

    @IBAction func chooseImage(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ScramblingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")]as? UIImage{
//            uploadImage.image = image
//        }
        uploadImage.image = scramblingPlaceholderBefore;
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        uploadImage.image = scramblingPlaceholderBefore;
        picker.dismiss(animated: true, completion: nil)
    }
}
