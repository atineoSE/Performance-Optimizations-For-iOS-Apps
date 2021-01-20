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
    private let posterIds: [String]
    private var posterImages: [String: UIImage] = [:]

    init(posterIds: [String]) {
        self.posterIds = posterIds
    }

    func sizeForPoster(at indexPath: IndexPath) -> CGSize {
        return photoSize
    }

    func posterId(at indexPath: IndexPath) -> String {
        return posterIds[indexPath.row]
    }
    
    func store(poster: UIImage, at indexPath: IndexPath) {
        posterImages[posterIds[indexPath.row]] = poster
    }
    
    func poster(at indexPath: IndexPath) -> UIImage? {
        return posterImages[posterIds[indexPath.row]]
    }
}

extension PhotoCollectionDataSource : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posterIds.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = SimplePhotoCollectionViewCell.Identifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! SimplePhotoCollectionViewCell
        cell.poster = UIImage(named: "movie_placeholder")!.resized(newHeight: imageHeight ?? SimplePhotoCollectionViewCell.defaultCellSize.height)
        
        return cell
    }
}
