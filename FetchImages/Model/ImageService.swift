import DogPicsLibrary
import CoreData
import UIKit
protocol ImageServiceProtocol {
    func fetchSingleImage(completion: @escaping (UIImage?) -> Void)
    func fetchImagesFromServer(count: Int, completion: @escaping (UIImage?) -> Void)
    func fetchSingleImageFromDB(atIndex index: Int, completion: @escaping (UIImage?) -> Void)
}

class ImageService: ImageServiceProtocol{
    
    private let context = CoreDataManager.shared.context
    
     var countOfImagesInDB : Int{
        let fetchRequest = DogImage.fetchRequest()
        var countOfImages = 0
        do{
            countOfImages = try context.count(for: fetchRequest)
        }catch{
            print("Could not fetch count. \(error), \(error.localizedDescription)")
        }
        
        return countOfImages
    }
    
    func fetchSingleImage(completion: @escaping (UIImage?) -> Void) {
            Task{
                let image =  await FetchDogImages().getImage()
                storeImagesInDatabase([image]){
                    let imageIndextoFetch = self.countOfImagesInDB
                    self.fetchSingleImageFromDB(atIndex: imageIndextoFetch){image in
                        completion(image)
                    }
                }
            }
    }
    
    func fetchNextImage(index:Int, completion: @escaping (UIImage?) -> Void){
        if  index < countOfImagesInDB{
            fetchSingleImageFromDB(atIndex: index) { image in
                completion(image)
            }
        }else{
            fetchSingleImage { image in
                completion(image)
            }
        }
    }
    
    func fetchImagesFromServer(count: Int, completion: @escaping (UIImage?) -> Void) {
        Task{
            guard let images = await FetchDogImages().getImages(withCount: count) else {
                return
            }
            storeImagesInDatabase(images){
                let imageIndextoFetch = self.countOfImagesInDB
                self.fetchSingleImageFromDB(atIndex: imageIndextoFetch){image in
                    completion(image)
                }
            }
        }
    }
    
    func fetchSingleImageFromDB(atIndex index: Int, completion: @escaping (UIImage?) -> Void) {
        let context = CoreDataManager.shared.context
        let fetchRequest = DogImage.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "index == %d",Int32(index))
        do{
            let dogImages = try context.fetch(fetchRequest)
            if let imageData = dogImages.first?.imageData{
                let image = UIImage(data: imageData)
                completion(image)
            }else{
                completion(nil)
            }            
        }catch{
            print("Could not fetch images. \(error), \(error.localizedDescription)")
            completion(nil)
        }
    }
}



private func storeImagesInDatabase(_ images:[UIImage?],completion: @escaping () -> Void){
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
        completion()
    } catch let error as NSError {
        completion()
    }
}
