
import UIKit
class ViewController: UIViewController {
    
    var count  = 0
    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func fetchImages(_ sender: Any) {
        guard let text = textField.text,
              let value = Int(text)
        else {return}
        count = value
        
        guard let vc = storyboard?.instantiateViewController(identifier: "ImageViewController") as? DogImageViewController else {
            return
        }
        present(vc, animated: true)
        vc.numberOfImagesToFetch = count
    }
    
    @IBAction func loadExistingImages(_ sender: Any) {
        
    }
    
    
    @IBAction func deleteAllOlderImages(_ sender: Any) {
        CoreDataManager.shared.deleteAllDogImages()
    }
    
    
}

