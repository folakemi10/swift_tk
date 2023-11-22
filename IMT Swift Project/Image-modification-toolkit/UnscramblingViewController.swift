//
//  UnscramblingViewController.swift
//  Image-modification-toolkit
//
//  Created by Juncheng Yang on 11/7/23.
//

import UIKit
import SwiftImage
import SwiftUI

class UnscramblingViewController: UIViewController {

    @IBOutlet weak var uploadImage2: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    var unscramblingPlaceholderBefore: UIImage = UIImage(named: "scrambledplaceholder")!

        var unscramblingPlaceholderAfter: UIImage = UIImage(named: "normalplaceholder")!
    
    var safePrimes: [Int] = [5, 7, 11, 23, 47, 59, 83, 107, 167, 179, 227, 263, 347, 359, 383, 467, 479, 503, 563, 587, 719, 839, 863, 887, 983, 1019, 1187, 1283, 1307, 1319, 1367, 1439, 1487, 1523, 1619, 1823, 1907, 2027, 2039, 2063, 2099, 2207, 2447, 2459, 2579, 2819, 2879, 2903, 2963, 2999, 3023, 3119, 3167, 3203, 3467, 3623, 3779, 3803, 3863, 3947, 4007, 4079, 4127, 4139, 4259, 4283, 4547, 4679, 4703, 4787, 4799, 4919]

    var unscrambledUIImage: UIImage?
    
    @IBOutlet weak var keyField: UITextField!
    
    @IBAction func chooseImage2(_ sender: Any) {
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
extension UnscramblingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")]as? UIImage{
            uploadImage2.image = image
            
            var imc = ImageModificationClass(imageArg: uploadImage2.image!)
            if let inputText = keyField.text {
                let codeNumbers = inputText.components(separatedBy: " ")
                
                var codeNums: [Int] = []
                
                //TODO: check if the decryption key is of the valid (13-number) format and generate an error message if it's not
                
                for i in 0..<codeNumbers.count {
                    if let intValue = Int(codeNumbers[i]) {
                        codeNums.append(intValue)
                    }
                }
                
                var safePrimeIndex = codeNums[12]
                
                var root1 = codeNums[0]
                var root2 = codeNums[1]
                var root3 = codeNums[2]
                var root4 = codeNums[3]
                var root5 = codeNums[4]
                var root6 = codeNums[5]
                
                var a1 = codeNums[6]
                var a2 = codeNums[7]
                var a3 = codeNums[8]
                var a4 = codeNums[9]
                var a5 = codeNums[10]
                var a6 = codeNums[11]
                
                var pxSize = Int(Int(uploadImage2.frame.width) / safePrimes[safePrimeIndex])
                
                imc.setMosaicPixelSize(pxSize: pxSize)
                
                imc.setSafePrimeIndex(spIndex: safePrimeIndex)
                
                imc.enhancedMosaicDecrypt(pr1: root1, pr2: root2, pr3: root3, pr4: root4, pr5: root5, pr6: root6, a1: a1, a2: a2, a3: a3, a4: a4, a5: a5, a6: a6, sPrime: safePrimes[safePrimeIndex])
                
                var unscrambledImage = imc.getCurrentImage()

                unscrambledUIImage = unscrambledImage.uiImage
            }
        }
        //uploadImage2.image = unscramblingPlaceholderBefore
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //uploadImage2.image = unscramblingPlaceholderBefore
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "finishedUnscrambling") {
            if let finished = segue.destination as? UnscramblingFinishedViewController {
                finished.unscrambledResult = unscrambledUIImage
            }
        }
    }
}
