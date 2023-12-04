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
    var keyValid: Bool = false

    var unscramblingPlaceholderBefore: UIImage = UIImage(named: "scrambledplaceholder")!

        var unscramblingPlaceholderAfter: UIImage = UIImage(named: "normalplaceholder")!
    
    var safePrimes: [Int] = [5, 7, 11, 23, 47, 59, 83, 107, 167, 179, 227, 263, 347, 359, 383, 467, 479, 503, 563, 587, 719, 839, 863, 887, 983, 1019, 1187, 1283, 1307, 1319, 1367, 1439, 1487, 1523, 1619, 1823, 1907, 2027, 2039, 2063, 2099, 2207, 2447, 2459, 2579, 2819, 2879, 2903, 2963, 2999, 3023, 3119, 3167, 3203, 3467, 3623, 3779, 3803, 3863, 3947, 4007, 4079, 4127, 4139, 4259, 4283, 4547, 4679, 4703, 4787, 4799, 4919]

    var unscrambledUIImage: UIImage?
    
    var inputText: String?
    
    @IBOutlet weak var keyField: UITextField!
    
    @IBAction func editingEnded(_ sender: Any) {
        inputText = keyField.text
    }
    
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
            
            print("went in here")
            
        }
        //uploadImage2.image = unscramblingPlaceholderBefore
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //uploadImage2.image = unscramblingPlaceholderBefore
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func codeValid (inputArray: [Int], spIndex: Int) -> Bool {
        var status: Bool = true
        
        for i in 0..<6 {
            if (!getProots(spIndex: spIndex).contains(inputArray[i])) {
                status = false
            }
        }
        for i in 6..<12 {
            if (!getRelPrimes(spIndex: spIndex).contains(inputArray[i])) {
                status = false
            }
        }
        
        return status
    }
    
    func getProots (spIndex: Int) -> [Int]{
        let safePrime = safePrimes[spIndex]
        var proots: [Int] = []
        for i in 0..<(safePrime-1) {
            proots.append(i)
        }
        for i in 0..<safePrime {
            if let j = proots.firstIndex(of: ((i*i) % safePrime)) {
                proots.remove(at: j)
            }
        }
        return proots
    }
    
    func getRelPrimes (spIndex: Int) -> [Int] {
        let safePrime = safePrimes[spIndex]
        var relPrimes: [Int] = []
        for i in 0..<(safePrime-1) {
            if ((i % 2 == 1) && (i != (safePrime - 1) / 2)) {
                relPrimes.append(i)
            }
        }
        return relPrimes
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        unscrambleImg()
        if keyValid == false {
            self.showAlert(message: "Invalid Key/Missing Image")
            return
        }
        if (segue.identifier == "finishedUnscrambling") {
            if let finished = segue.destination as? UnscramblingFinishedViewController {
                finished.unscrambledResult = unscrambledUIImage
            }
        }
    }
    func unscrambleImg() {
        let imc = ImageModificationClass(imageArg: uploadImage2.image!)
        print("idk idk")

        print("is the input text nil? \(inputText == nil)")
        if (inputText != nil) {
            let regexKey = /(\d+\s){12}\d+/
            if !inputText!.contains(regexKey) {
                print("Invalid Key")
                keyValid = false
                self.showAlert(message: "Invalid Key")
                return
            }
            
            print("the key is now valid!")
            keyValid = true
            let codeNumbers = inputText!.components(separatedBy: " ")
            
            var codeNums: [Int] = []
            
                    
            for i in 0..<codeNumbers.count {
                if let intValue = Int(codeNumbers[i]) {
                    codeNums.append(intValue)
                }
            }
            
            let safePrimeIndex = codeNums[12]
            
            let root1 = codeNums[0]
            let root2 = codeNums[1]
            let root3 = codeNums[2]
            let root4 = codeNums[3]
            let root5 = codeNums[4]
            let root6 = codeNums[5]
            
            let a1 = codeNums[6]
            let a2 = codeNums[7]
            let a3 = codeNums[8]
            let a4 = codeNums[9]
            let a5 = codeNums[10]
            let a6 = codeNums[11]
            
            
            if (!codeValid(inputArray: codeNums, spIndex: safePrimeIndex)) {
                print("unscrambling unsuccessful")
                self.showAlert(message: "Invalid Key")
                return
            }
            let pxSize = Int(Int(uploadImage2.frame.width) / safePrimes[safePrimeIndex])
            
            imc.setMosaicPixelSize(pxSize: pxSize)
            
            imc.setSafePrimeIndex(spIndex: safePrimeIndex)
            
            imc.enhancedMosaicDecrypt(pr1: root1, pr2: root2, pr3: root3, pr4: root4, pr5: root5, pr6: root6, a1: a1, a2: a2, a3: a3, a4: a4, a5: a5, a6: a6, sPrime: safePrimes[safePrimeIndex])
            
            print("unscrambling successful")
            let unscrambledImage = imc.getCurrentImage()

            unscrambledUIImage = unscrambledImage.uiImage
        }
    }
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
