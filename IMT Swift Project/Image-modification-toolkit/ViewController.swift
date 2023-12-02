//
//  ViewController.swift
//  Image-modification-toolkit
//
//  Created by Juncheng Yang on 11/7/23.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var imageView: UICollectionView!
    
    var imageArray = ["logo-png","m2","m3"]
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(autoPage), userInfo: nil, repeats: true)
    }
    
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            if let registerViewController = self.storyboard?.instantiateViewController(withIdentifier: "registerViewController") {
                if let navigationController = self.navigationController {
                    navigationController.setViewControllers([registerViewController], animated: true)
                }
            }
            
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    @objc func autoPage(){
        if index < imageArray.count - 1 {
            index = index + 1
        }else {
            index = 0
        }
        pageControl.numberOfPages = imageArray.count
        pageControl.currentPage = index
        imageView.scrollToItem(at: IndexPath(item: index, section: 0), at: .right, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCusCollectionViewCell", for: indexPath) as? CustomCusCollectionViewCell
        cell?.imageGalary.image = UIImage(named: imageArray[indexPath.row])
        cell?.layer.borderWidth = 1
        cell?.layer.borderColor = UIColor.white.cgColor
        cell?.layer.cornerRadius = 20
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

