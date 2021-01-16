import Foundation
import UIKit

class PhotoCollectionDataSource : NSObject {
    private var photoSize: CGSize = SimplePhotoCollectionViewCell.defaultCellSize
    var imageHeight: CGFloat? {
        didSet {
            guard let imageHeight = imageHeight, let sampleImage = UIImage(named: "movie_placeholder") else { return }
            photoSize = sampleImage.resized(newHeight: imageHeight).size
        }
    }
    private let posters: [UIImage]

    init(posters: [UIImage]) {
        self.posters = posters
    }

    func sizeForPoster(at indexPath: IndexPath) -> CGSize {
        return photoSize
    }

    func poster(at indexPath: IndexPath) -> UIImage? {
        return posters[indexPath.row]
    }
}

extension PhotoCollectionDataSource : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posters.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = SimplePhotoCollectionViewCell.Identifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! SimplePhotoCollectionViewCell
        cell.poster = posters[indexPath.row]
        
        return cell
    }
}
