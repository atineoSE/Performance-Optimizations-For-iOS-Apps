import UIKit

class SimplePhotoCollectionViewCell: UICollectionViewCell {
    static let Identifier = "SimplePhotoCollectionViewCell"
    static let defaultCellSize = CGSize(width: 300.0, height: 200.0)
    
    @IBOutlet private weak var photoImageView: UIImageView!
    
    func set(poster: UIImage, animated:Bool = false) {
        if (animated) {
            UIView.transition(with: photoImageView, duration: 0.2, options: .transitionCrossDissolve, animations: { [weak self] in
                self?.photoImageView.image = poster
            }, completion: nil)
        } else {
            photoImageView.image = poster
        }
    }
}
