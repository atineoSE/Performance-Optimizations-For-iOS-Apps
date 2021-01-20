import UIKit

class PhotoViewController: UIViewController {
    @IBOutlet weak var photoDetail: UIImageView!
    
    @IBAction func didTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var networkController: NetworkController?
    var posterId: String?
    
    override func viewDidLoad() {
        guard let posterId = posterId else  { return }
        
        networkController = NetworkController()
        
        networkController?.fetchFilmPoster(posterId: posterId) { [weak self] posterData in
            guard let strongSelf = self else { return }
            if let poster = UIImage(data: posterData) {
                strongSelf.photoDetail.image = poster
                strongSelf.photoDetail.accessibilityIdentifier = "PosterDetail"
            }
        }
    }
}
