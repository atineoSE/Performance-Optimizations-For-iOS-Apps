import UIKit

class PhotoViewController: UIViewController {
    @IBOutlet weak var photoDetail: UIImageView!
    
    @IBAction func didTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var poster: UIImage? {
        didSet {
            if (isOnScreen) {
                print("Updated image for high-res one")
                UIView.transition(with: photoDetail, duration: 0.2, options: .transitionCrossDissolve, animations: { self.photoDetail.image = self.poster }, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        photoDetail.image = poster
        photoDetail.accessibilityIdentifier = "PosterDetail"
    }
}
