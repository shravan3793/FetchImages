import UIKit
extension ImageViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell
        else{
            return UICollectionViewCell()
        }
        cell.imageView.image = arrImages?[indexPath.item] ?? UIImage(resource: ImageResource.placeholder)
        print("\(indexPath.section)  \(indexPath.item)")
        return cell
    }
}
