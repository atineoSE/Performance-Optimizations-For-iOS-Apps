import UIKit

class PhotoCollectionViewController: UIViewController {
    static let ShowPhotoDetailsSegueIdentifier = "ShowPhotoDetails"
    static let Identifier = "PhotoCollectionViewController"
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    private var networkController: NetworkController?
    private var dataSource: PhotoCollectionDataSource?
    private var selectedPoster: UIImage?
    
    var containerSize: CGSize? {
        didSet {
            guard let containerSize = containerSize else { return }
            configureDataSource(with: containerSize)
            setCollectionViewLayout(with: containerSize.height)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize network controller
        networkController = NetworkController()
        
        // Initialize data source
        dataSource = PhotoCollectionDataSource(posterIds: FilmPosters.posterIds)
        
        // Connect dependencies
        photoCollectionView.dataSource = dataSource
        photoCollectionView.delegate = self
        
        // Register photo cell
        let identifier = SimplePhotoCollectionViewCell.Identifier
        let nib = UINib(nibName: identifier, bundle: nil)
        photoCollectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    private func configureDataSource(with size:CGSize) {
        dataSource?.imageHeight = size.height
    }
    
    private func setCollectionViewLayout(with height: CGFloat) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        photoCollectionView.setCollectionViewLayout(flowLayout, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? PhotoViewController,
            segue.identifier == PhotoCollectionViewController.ShowPhotoDetailsSegueIdentifier else
        {
            return
        }
        
        destination.poster = selectedPoster
    }
    
    func showPhotoDetails() {
        performSegue(withIdentifier: PhotoCollectionViewController.ShowPhotoDetailsSegueIdentifier, sender: self)
    }
}

extension PhotoCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt \(indexPath)")
        selectedPoster = dataSource?.poster(at: indexPath)
        showPhotoDetails()
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SimplePhotoCollectionViewCell,
              let networkController = networkController,
              let dataSource = dataSource
        else {
            return
        }
        
        if let poster = dataSource.poster(at: indexPath) {
            cell.set(poster: poster)
        } else {
            networkController.fetchFilmPoster(posterId: dataSource.posterId(at: indexPath)) { [weak self] posterData in
                if let poster = UIImage(data: posterData) {
                    dataSource.store(poster: poster, at: indexPath)
                    print("Fetched image at \(indexPath.row) (\(dataSource.posterId(at: indexPath)))")
                    if (self?.photoCollectionView?.indexPathsForVisibleItems.contains(indexPath) ?? false) {
                        if let cell = self?.photoCollectionView?.cellForItem(at: indexPath) as? SimplePhotoCollectionViewCell {
                            cell.set(poster: poster, animated: true)
                        }
                    }
                }
            }
        }
    }
}

extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout  {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return dataSource?.sizeForPoster(at: indexPath) ?? SimplePhotoCollectionViewCell.defaultCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
