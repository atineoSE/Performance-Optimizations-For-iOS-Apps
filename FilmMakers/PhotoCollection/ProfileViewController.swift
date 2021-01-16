import Foundation
import UIKit

class ProfileViewController: UIViewController {
    var containerViewController: PhotoCollectionViewController?
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profilePhotoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var containerSize: CGSize {
        return CGSize(width: view.frame.size.width, height: view.frame.size.height - profileView.frame.size.height + 24.0)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func initializeContainer() {
            // instantiate container view controller and add to hierarchy
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let photoCollectionViewController = storyboard.instantiateViewController(withIdentifier: "PhotoCollectionViewControllerStoryboardIdentifier") as! PhotoCollectionViewController
            addChild(photoCollectionViewController)
            containerView.addSubview(photoCollectionViewController.view)
            photoCollectionViewController.didMove(toParent: self)
            
            // set Auto Layout constraints
            photoCollectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
            containerView.topAnchor.constraint(equalTo: photoCollectionViewController.view.topAnchor).isActive = true
            containerView.leadingAnchor.constraint(equalTo: photoCollectionViewController.view.leadingAnchor).isActive = true
            containerView.trailingAnchor.constraint(equalTo: photoCollectionViewController.view.trailingAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: photoCollectionViewController.view.bottomAnchor).isActive = true
            
            // Hold onto reference for future use
            containerViewController = photoCollectionViewController
            
            
        }
        
        // Initialize container
        initializeContainer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let containerViewController = containerViewController, containerViewController.containerSize == nil else { return }
        containerViewController.containerSize = containerSize
    }
}
