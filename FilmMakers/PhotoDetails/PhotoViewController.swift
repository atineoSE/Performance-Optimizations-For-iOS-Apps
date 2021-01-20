import UIKit

class PhotoViewController: UIViewController {
    @IBOutlet weak var photoDetail: UIImageView!
    
    @IBAction func didTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var poster: UIImage?
    
    override func viewDidLoad() {
        photoDetail.image = poster
        photoDetail.accessibilityIdentifier = "PosterDetail"
    }
}
