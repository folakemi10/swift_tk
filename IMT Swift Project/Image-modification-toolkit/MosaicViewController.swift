////
////  MosaicViewController.swift
////  Image-modification-toolkit
////
////  Created by Juncheng Yang on 11/7/23.
////
//
//import UIKit
//import SwiftImage
//
//class MosaicViewController: UIViewController {
//    var size: Int = 10
//    var height: Int = 600
//    var width: Int = 600
//    var mosaicImage: UIImage?
//    @IBOutlet weak var uploadImage3: UIImageView!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let menuClosure = {(action: UIAction) in
//            print("")
//        }
//        imageBank.menu = UIMenu(children: [
//            UIAction(title: "Emoji Squares", state: .on, handler: menuClosure),
//            UIAction(title: "none", handler: menuClosure)])
//
//    }
//    var mosaicPlaceholderBefore: UIImage = UIImage(named: "normalplaceholder")!
//
//       var mosaicPlaceholderAfter: UIImage = UIImage(named: "emojifiedplaceholder")!
//
//    @IBOutlet weak var imageBank: UIButton!
//
//    @IBOutlet weak var sizeValue: UITextField!
//    @IBAction func sizeChanged(_ sender: Any) {
//    }
//    @IBOutlet weak var heightValue: UITextField!
//    @IBAction func heightChanged(_ sender: Any) {
//    }
//    @IBOutlet weak var widthValue: UITextField!
//    @IBAction func widthChanged(_ sender: Any) {
//    }
//
//    @IBAction func chooseImage3(_ sender: Any) {
//        let vc = UIImagePickerController()
//        vc.sourceType = .photoLibrary
//        vc.delegate = self
//        vc.allowsEditing = true
//        present(vc, animated: true)
//    }
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
//
//extension MosaicViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")]as? UIImage{
//            uploadImage3.image = image
//            let imc = ImageModificationClass(imageArg: uploadImage3.image!)
//            imc.emojify(width: width, height: height, emojiSize: size)
//            let mosaic:Image<RGBA<UInt8>> = imc.getCurrentImage()
//            mosaicImage = mosaic.uiImage
//
//        }
////        uploadImage3.image = mosaicPlaceholderBefore;
//        picker.dismiss(animated: true, completion: nil)
//    }
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
////        uploadImage3.image = mosaicPlaceholderBefore;
//        picker.dismiss(animated: true, completion: nil)
//    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "finishedMosaic") {
//            if let finished = segue.destination as? MosaicFinishedViewController {
//                finished.mosaicResult = mosaicImage
//            }
//        }
//    }
//}
