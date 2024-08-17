import UIKit
import Combine
class ImageControllerViewModel{
    private let dogImageService : ImageService
    var isLoading = CurrentValueSubject<Bool, Never>(false)
    @Published var images: [UIImage?] = []
    private var countOfImages = 0
    
    init(countOfImages:Int,dogImageService : ImageService = ImageService()) {
        self.dogImageService = dogImageService
    }
    
    ///load multple images from library with a specific count
    func loadImages(count:Int){
        isLoading.send(true)
        dogImageService.fetchImagesFromServer(count: count) { image in
            self.images.append(image)
            self.isLoading.send(false)
        }
    }
    
    func nextImage(index:Int){
        isLoading.send(true)
        dogImageService.fetchNextImage(index: index) { image in
            self.images.append(image)
            self.isLoading.send(false)
        }
    }
    
    func previousImage(index:Int){

        dogImageService.fetchSingleImageFromDB(atIndex: index){image in
            self.images.append(image)
        }
    }
    
}
