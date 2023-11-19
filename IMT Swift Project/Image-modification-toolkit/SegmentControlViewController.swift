//
//  SegmentControlViewController.swift
//  Image-modification-toolkit
//
//  Created by Juncheng Yang on 11/7/23.
//

import UIKit

class SegmentControlViewController: UIViewController {

    @IBOutlet weak var changeSegment: UISegmentedControl!
    private var firstViewController: UIViewController?
    private var secondViewController: UIViewController?
    private var thirdViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFirstViewController()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func didSegmentChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
                    removeThirdViewController()
                    removeSecondViewController()
                    loadFirstViewController()
                } else if sender.selectedSegmentIndex == 1{
                    removeThirdViewController()
                    removeFirstViewController()
                    loadSecondViewController()
                } else{
                    removeFirstViewController()
                    removeSecondViewController()
                    loadThirdViewController()
                }
    }
    
    private func loadFirstViewController() {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScramblingViewController") {
                addChild(vc)
                vc.view.frame = self.view.bounds
                self.view.addSubview(vc.view)
                vc.didMove(toParent: self)
                firstViewController = vc
            }
        }

        private func removeFirstViewController() {
            firstViewController?.willMove(toParent: nil)
            firstViewController?.view.removeFromSuperview()
            firstViewController?.removeFromParent()
            firstViewController = nil
        }

        private func loadSecondViewController() {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "UnscramblingViewController") {
                addChild(vc)
                vc.view.frame = self.view.bounds
                self.view.addSubview(vc.view)
                vc.didMove(toParent: self)
                secondViewController = vc
            }
        }

        private func removeSecondViewController() {
            secondViewController?.willMove(toParent: nil)
            secondViewController?.view.removeFromSuperview()
            secondViewController?.removeFromParent()
            secondViewController = nil
        }
    
    private func loadThirdViewController() {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MosaicViewController") {
                addChild(vc)
                vc.view.frame = self.view.bounds
                self.view.addSubview(vc.view)
                vc.didMove(toParent: self)
                thirdViewController = vc
            }
        }
    
    private func removeThirdViewController() {
        secondViewController?.willMove(toParent: nil)
        secondViewController?.view.removeFromSuperview()
        secondViewController?.removeFromParent()
        secondViewController = nil
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
