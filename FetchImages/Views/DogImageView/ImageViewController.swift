import UIKit
import DogPicsLibrary
import CoreData
import Combine
class ImageViewController: UIViewController {
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var viewModel : ImageControllerViewModel!
    var selectedIndex = 0
    var arrImages : [UIImage?]? = []{
        didSet{
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    var numberOfImagesToFetch : Int = 0
    var cancellables = Set<AnyCancellable>()
    var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()

    }
    
    private func initialSetup(){
        viewModel = ImageControllerViewModel(countOfImages: numberOfImagesToFetch)
        setupActivityIndicator()
        updateButtonStates()
        setupCollectionView()
        setupBindings()
        viewModel.loadImages(count: numberOfImagesToFetch)
    }
    
    private func setupActivityIndicator() {
            activityIndicator = UIActivityIndicatorView (style: .large)
            activityIndicator.center = view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.backgroundColor = .white
            view.addSubview(activityIndicator)
        }
    
    private func setupBindings(){
        
        viewModel.isLoading
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] isLoading in
                        if isLoading {
                            self?.activityIndicator.startAnimating()
                            self?.view.isUserInteractionEnabled = false
                        } else {
                            self?.activityIndicator.stopAnimating()
                            self?.view.isUserInteractionEnabled = true
                        }
                    }.store(in: &cancellables)
        
        viewModel.$images
            .receive(on: DispatchQueue.main)
            .sink { [weak self] images in
            self?.arrImages = images
            if let count = self?.arrImages?.count, count > 0{
                self?.scroll(to: self?.selectedIndex ?? 0)
            }
        }.store(in: &cancellables)
    }
    
    private func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        
        collectionView.dataSource = self
        collectionView.isPagingEnabled = false
        collectionView.isUserInteractionEnabled = false
    }
    
    
    @IBAction func previousImage(_ sender: Any) {
        selectedIndex = selectedIndex - 1
        scroll(to: selectedIndex)
        updateButtonStates()
    }
    
    @IBAction func nextImage(_ sender: Any) {
        selectedIndex += 1
        viewModel.nextImage(index: selectedIndex)
    }
    
    func scroll(to index:Int){
        DispatchQueue.main.async {
            let indexpath = IndexPath(item: index, section: 0)
            self.collectionView.scrollToItem(at:indexpath , at: .centeredHorizontally, animated: true)
            self.collectionView.layoutIfNeeded()
            self.selectedIndex = index
            self.updateButtonStates()
        }
    }
    
    private func updateButtonStates() {
        btnPrevious.isEnabled = selectedIndex > 0
    }
    
}






