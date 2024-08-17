import UIKit
import DogPicsLibrary
import CoreData
class DogImageViewController: UIViewController {
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedIndex = 0
    var countOfImagesInDB : Int{
        let context = CoreDataManager.shared.context
        let fetchRequest = DogImage.fetchRequest()
        var countOfImages = 0
        do{
            countOfImages = try context.count(for: fetchRequest)
        }catch{
            print("Could not fetch count. \(error), \(error.localizedDescription)")
        }
        
        return countOfImages
    }
    
    var arrImages : [UIImage?]? = []{
        didSet{
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    var numberOfImagesToFetch : Int = 0  {
        didSet{
            self.loadCollectionView()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    private func initialSetup(){
        CoreDataManager.shared.printDatabasePath()
        btnPrevious.isEnabled = false
        collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionView.isPagingEnabled = false
        collectionView.isUserInteractionEnabled = false
        
    }
    
    func loadCollectionView(){
        Task{
            guard let images = await FetchDogImages().getImages(withCount: self.numberOfImagesToFetch) else {
                return
            }
            storeImagesInDatabase(images){
                self.fetchAllImagesFromDatabase()
            }
            
        }
    }
    
    
    @IBAction func previousImage(_ sender: Any) {
        
        let updatedIndex = selectedIndex - 1
        collectionView.scrollToItem(at: IndexPath(item: updatedIndex, section: 0), at: .centeredHorizontally, animated: true)
        selectedIndex = updatedIndex
        btnPrevious.isEnabled = selectedIndex != 0 ? true : false
        
    }
    @IBAction func nextImage(_ sender: Any) {
        
        if countOfImagesInDB == selectedIndex+1{
            fetchSingleImageFromServer()
            
        }else{
            scroll(to: selectedIndex+1)
        }
    }
    
    func scroll(to index:Int){
        DispatchQueue.main.async {
            let indexpath = IndexPath(item: index, section: 0)
            self.collectionView.scrollToItem(at:indexpath , at: .centeredHorizontally, animated: true)
            self.collectionView.layoutIfNeeded()
            self.selectedIndex = index
            self.btnPrevious.isEnabled = true
        }
        
    }
    
}



extension DogImageViewController {
    func fetchSingleImageFromServer(){
        Task{
            let image =  await FetchDogImages().getImage()
            storeImagesInDatabase([image]){
                let imageIndextoFetch = self.countOfImagesInDB
                self.fetchImageFromDB(atIndex: imageIndextoFetch){
                    self.scroll(to: self.selectedIndex+1)
                }
            }
        }
    }
    
    func fetchAllImagesFromDatabase(){
        arrImages = []
        let context = CoreDataManager.shared.context
        let fetchRequest = DogImage.fetchRequest()
        do{
            let dogImages = try context.fetch(fetchRequest)
            for dogImage in dogImages {
                if let imageData = dogImage.imageData{
                    let image = UIImage(data: imageData)
                    arrImages?.append(image)
                }
            }
        }catch{
            print("Could not fetch images. \(error), \(error.localizedDescription)")
        }
    }
    
    func storeImagesInDatabase(_ images:[UIImage?],completion: @escaping () -> Void){
        let context = CoreDataManager.shared.context
        let fetchRequest = DogImage.fetchRequest()
        var currentMaxIndexinDB = 0
        do{
            currentMaxIndexinDB = try context.count(for: fetchRequest)
        }catch{
            print("Could not fetch count. \(error), \(error.localizedDescription)")
        }
        
        for image in images {
            if let imageData = image?.jpegData(compressionQuality: 1.0) {
                let dogImage = DogImage(context: context)
                dogImage.imageData = imageData
                currentMaxIndexinDB += 1
                dogImage.index = Int32(currentMaxIndexinDB)
            }
        }
        
        do {
            try context.save()
            print("Images saved successfully!")
            completion()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            completion()
        }
    }
    
    func fetchImageFromDB(atIndex index:Int,completion: @escaping ()-> Void){
        let context = CoreDataManager.shared.context
        let fetchRequest = DogImage.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "index == %d",Int32(index))
        do{
            let dogImages = try context.fetch(fetchRequest)
            if let imageData = dogImages.first?.imageData{
                let image = UIImage(data: imageData)
                arrImages?.append(image)
            }
            completion()
        }catch{
            print("Could not fetch images. \(error), \(error.localizedDescription)")
            completion()
        }
    }
}


