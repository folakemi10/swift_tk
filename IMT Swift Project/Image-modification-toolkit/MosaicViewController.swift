//
//  MosaicViewController.swift
//  Image-modification-toolkit
//
//  Created by Juncheng Yang on 11/7/23.
//

import UIKit

class MosaicViewController: UIViewController {

    @IBOutlet weak var uploadImage3: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    var mosaicPlaceholderBefore: UIImage = UIImage(named: "normalplaceholder")!

       var mosaicPlaceholderAfter: UIImage = UIImage(named: "emojifiedplaceholder")!
    

    
    @IBAction func chooseImage3(_ sender: Any) {
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

extension MosaicViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")]as? UIImage{
//            uploadImage3.image = image
//        }
        uploadImage3.image = mosaicPlaceholderBefore;
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        uploadImage3.image = mosaicPlaceholderBefore;
        picker.dismiss(animated: true, completion: nil)
    }
}
