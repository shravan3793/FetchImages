import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
 
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFit
    }
    
}
