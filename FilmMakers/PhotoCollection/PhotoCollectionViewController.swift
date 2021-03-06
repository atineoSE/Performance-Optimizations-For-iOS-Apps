import UIKit

class PhotoCollectionViewController: UIViewController {
    static let ShowPhotoDetailsSegueIdentifier = "ShowPhotoDetails"
    static let Identifier = "PhotoCollectionViewController"
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    private var networkController: NetworkController?
    private var dataSource: PhotoCollectionDataSource?
    private var persistenceController: InMemoryRepo?
    private var selectedIndexPath: IndexPath?
    
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
        
        // Initialize persistence controller
        persistenceController = InMemoryRepo()
        
        // Initialize data source
        dataSource = PhotoCollectionDataSource(posterIds: FilmPosters.posterIds)
        
        // Connect dependencies
        photoCollectionView.dataSource = dataSource
        photoCollectionView.delegate = self
        photoCollectionView.prefetchDataSource = self
        
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
        if let selectedIndexPath = selectedIndexPath {
            inject(posterIndexPath: selectedIndexPath, into: destination)
        }
    }
    
    private func inject(posterIndexPath:IndexPath, into photoViewController: PhotoViewController) {
        guard let dataSource = dataSource,
            let networkController = networkController,
            let persistenceController = persistenceController
            else {
                return
        }
        
        let posterId = dataSource.posterId(at: posterIndexPath)
        if let poster = persistenceController.retrieve(posterId: posterId) {
            photoViewController.poster = poster
        } else {
            photoViewController.poster = dataSource.poster(at: posterIndexPath)
            networkController.fetchFilmPoster(posterId: posterId, small: false) { [weak self] posterData in
                if let poster = UIImage(data: posterData) {
                    self?.persistenceController?.save(posterId: posterId, poster: poster)
                    photoViewController.poster = poster
                    print("Fetched big version for poster at index \(posterIndexPath)")
                }
            }
        }
    }

    
    func showPhotoDetails() {
        performSegue(withIdentifier: PhotoCollectionViewController.ShowPhotoDetailsSegueIdentifier, sender: self)
    }
    
    private func needsFetchingPoster(at indexPath: IndexPath) -> Bool {
        guard let networkController = networkController,
            let dataSource = dataSource else { return false }
        
        return !dataSource.hasPoster(at: indexPath) && !networkController.isFetching(posterId: dataSource.posterId(at: indexPath))
    }
    
    private func fetchItem(at indexPath: IndexPath) {
        guard let networkController = networkController, let dataSource = dataSource else { return }
        
        networkController.fetchFilmPoster(posterId: dataSource.posterId(at: indexPath), small: true) { [weak self] posterData in
            if let poster = UIImage(data: posterData) {
                self?.dataSource?.store(poster: poster, at: indexPath)
                if (self?.photoCollectionView?.indexPathsForVisibleItems.contains(indexPath) ?? false) {
                    if let cell = self?.photoCollectionView?.cellForItem(at: indexPath) as? SimplePhotoCollectionViewCell {
                        cell.set(poster: poster, animated: true)
                    }
                }
            }
        }
    }
}

extension PhotoCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt \(indexPath)")
        selectedIndexPath = indexPath
        showPhotoDetails()
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard
            let cell = cell as? SimplePhotoCollectionViewCell,
            let dataSource = dataSource
        else {
            return
        }

        if let poster = dataSource.poster(at: indexPath) {
            cell.set(poster: poster)
        } else if (needsFetchingPoster(at: indexPath)) {
            fetchItem(at: indexPath)
            print("Fetch image at \(indexPath.row)")
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

extension PhotoCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            if (needsFetchingPoster(at: indexPath)) {
                fetchItem(at: indexPath)
                print("Prefetch image at index \(indexPath.row)")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        guard let networkController = networkController, let dataSource = dataSource else { return }
        
        indexPaths.forEach {indexPath in
            networkController.cancelFetch(for: dataSource.posterId(at: indexPath))
            print("Cancelled prefetching of image \(dataSource.posterId(at: indexPath)) at index \(indexPath.row)")
        }
    }
}
