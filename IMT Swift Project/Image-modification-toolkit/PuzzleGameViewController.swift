//
//  PuzzleGameViewController.swift
//  Image-modification-toolkit
//
//  Created by Juncheng Yang on 11/7/23.
//

import UIKit
import SwiftImage
import SwiftUI

class PuzzleGameViewController: UIViewController {
    @IBOutlet weak var numPieces: UISlider!
    
    @IBOutlet weak var uploadImage4: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        numPieces.minimumValue = 0
        numPieces.maximumValue = 11
        numPieces.value = 3
        numPieces.isContinuous = false
        // Do any additional setup after loading the view.
    }
    
    var scrambledUIImage: UIImage?

    var safePrimeIndex: Int = 3
    
    var scramblingProgress: Double = 0.0
    
    var safePrimes: [Int] = [5, 7, 11, 23, 47, 59, 83, 107, 167, 179, 227, 263, 347, 359, 383, 467, 479, 503, 563, 587, 719, 839, 863, 887, 983, 1019, 1187, 1283, 1307, 1319, 1367, 1439, 1487, 1523, 1619, 1823, 1907, 2027, 2039, 2063, 2099, 2207, 2447, 2459, 2579, 2819, 2879, 2903, 2963, 2999, 3023, 3119, 3167, 3203, 3467, 3623, 3779, 3803, 3863, 3947, 4007, 4079, 4127, 4139, 4259, 4283, 4547, 4679, 4703, 4787, 4799, 4919]
    
    @IBAction func chooseImage4(_ sender: Any) {
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
    
    func scrambleImg() {
        safePrimeIndex = Int(numPieces.value)
        
        let pxSize = Int(Int(uploadImage4.frame.width) / safePrimes[safePrimeIndex])
        
        var imc = ImageModificationClass(imageArg: uploadImage4.image!)
        
        imc.setMosaicPixelSize(pxSize: pxSize)
        
        imc.setSafePrimeIndex(spIndex: safePrimeIndex)
        
        imc.enhancedMosaicEncrypt()
        
        let scrambledImage = imc.getCurrentImage()
        
        scrambledUIImage = scrambledImage.uiImage
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toPuzzle") {
            if let finished = segue.destination as? PuzzleInnerViewController {
                
                scrambleImg()
                finished.scrambledImage = scrambledUIImage
                finished.dimension = safePrimes[safePrimeIndex] - 1
                finished.safePrimeIndex = safePrimeIndex
            }
        }
    }

}

extension PuzzleGameViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")]as? UIImage{
            uploadImage4.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
