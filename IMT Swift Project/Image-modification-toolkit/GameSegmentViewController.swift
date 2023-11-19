//
//  GameSegmentViewController.swift
//  Image-modification-toolkit
//
//  Created by Juncheng Yang on 11/7/23.
//

import UIKit

class GameSegmentViewController: UIViewController {

    @IBOutlet weak var changeSegment: UISegmentedControl!
    private var firstViewController: UIViewController?
    private var secondViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadFirstViewController()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didSegmentChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
                    removeSecondViewController()
                    loadFirstViewController()
                } else {
                    removeFirstViewController()
                    loadSecondViewController()
                }
    }
    
    private func loadFirstViewController() {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PuzzleGameViewController") {
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
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "GuessGameViewController") {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
