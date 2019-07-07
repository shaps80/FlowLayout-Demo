import UIKit
import FlowLayout

final class Cell: UICollectionViewCell, NibLoadable {
    
    @IBOutlet weak var label: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        guard let attributes = layoutAttributes as? FlowLayoutAttributes else { return }
        print("\(#function) \(attributes.indexPath), isFirst: \(attributes.isFirstInSection), isLast: \(attributes.isLastInSection)")
    }
    
}
