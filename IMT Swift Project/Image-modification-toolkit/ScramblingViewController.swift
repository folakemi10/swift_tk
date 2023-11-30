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
    
    @IBOutlet weak var safePrimeSlider: UISlider!
    
    var scrambledUIImage: UIImage?
    
    var secretCode: String = ""
    
    var safePrimeIndex: Int = 3
    
    var safePrimes: [Int] = [5, 7, 11, 23, 47, 59, 83, 107, 167, 179, 227, 263, 347, 359, 383, 467, 479, 503, 563, 587, 719, 839, 863, 887, 983, 1019, 1187, 1283, 1307, 1319, 1367, 1439, 1487, 1523, 1619, 1823, 1907, 2027, 2039, 2063, 2099, 2207, 2447, 2459, 2579, 2819, 2879, 2903, 2963, 2999, 3023, 3119, 3167, 3203, 3467, 3623, 3779, 3803, 3863, 3947, 4007, 4079, 4127, 4139, 4259, 4283, 4547, 4679, 4703, 4787, 4799, 4919]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //var image = Image<RGBA<UInt8>>(named: "ImageName")!

        safePrimeSlider.minimumValue = 0
        safePrimeSlider.maximumValue = 11
        safePrimeSlider.value = 3
        safePrimeSlider.isContinuous = false

        
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
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")]as? UIImage{
            uploadImage.image = image

            
            
            
        }
        //uploadImage.image = scramblingPlaceholderBefore;
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //uploadImage.image = scramblingPlaceholderBefore;
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "finishedScrambling") {
            if let finished = segue.destination as? ScramblingFinishedViewController {
                
                scrambleImg()
                finished.displayImage = scrambledUIImage
                finished.codeString = secretCode
            }
        }
    }
    
    func scrambleImg() {
        safePrimeIndex = Int(safePrimeSlider.value)
        
        let pxSize = Int(Int(uploadImage.frame.width) / safePrimes[safePrimeIndex])
        
        let imc = ImageModificationClass(imageArg: uploadImage.image!)
        
        imc.setMosaicPixelSize(pxSize: pxSize)
        
        imc.setSafePrimeIndex(spIndex: safePrimeIndex)
        
        imc.enhancedMosaicEncrypt()
        
        let scrambledImage: Image<RGBA<UInt8>> = imc.getCurrentImage()
        
        
        scrambledUIImage = scrambledImage.uiImage
        
        secretCode = imc.getSecretCode()
    }
}
