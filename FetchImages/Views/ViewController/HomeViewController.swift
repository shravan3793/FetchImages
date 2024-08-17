
import UIKit
class HomeViewController: UIViewController {
    
    var count  = 0
    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dog Images"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.textField.endEditing(true)
    }
    
    @IBAction func fetchImages(_ sender: Any) {
        guard let text = textField.text,
              let value = Int(text)
        else {return}
        count = value
        
        guard let vc = storyboard?.instantiateViewController(identifier: "ImageViewController") as? ImageViewController else {
            return
        }
        self.navigationController?.pushViewController(vc, animated: true)
        vc.numberOfImagesToFetch = count
    }

    
    @IBAction func deleteAllOlderImages(_ sender: Any) {
        CoreDataManager.shared.deleteAllDogImages()
    }
    
    
}

