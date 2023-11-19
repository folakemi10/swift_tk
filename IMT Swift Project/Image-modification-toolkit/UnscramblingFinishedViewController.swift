import Foundation

import UIKit

class UnscramblingFinishedViewController: UIViewController {
    var unscramblingPlaceholderAfter: UIImage = UIImage(named: "normalplaceholder")!
    @IBOutlet weak var editedImage: UIImageView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
       
        editedImage.image = unscramblingPlaceholderAfter
       
    }
   
}
