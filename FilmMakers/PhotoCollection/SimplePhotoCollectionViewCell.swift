import UIKit

class SimplePhotoCollectionViewCell: UICollectionViewCell {
    static let Identifier = "SimplePhotoCollectionViewCell"
    static let defaultCellSize = CGSize(width: 300.0, height: 200.0)
    
    @IBOutlet private weak var photoImageView: UIImageView!
    
    var poster = UIImage() {
        didSet {
            photoImageView.image = poster
        }
    }
}
