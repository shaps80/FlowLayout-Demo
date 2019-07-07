import UIKit

final class Cell: UICollectionViewCell, NibLoadable {
    
    @IBOutlet weak var label: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
}
