import UIKit

open class FlowLayoutAttributes: UICollectionViewLayoutAttributes {
    
    /// Returns true if these attributes are for the first element in the associated section
    open var isFirstInSection: Bool = false
    
    /// Returns true if these attributes are for the last element in the associated section
    open var isLastInSection: Bool = false
    
    open override func copy(with zone: NSZone? = nil) -> Any {
        guard let copy = super.copy(with: zone) as? FlowLayoutAttributes else { fatalError() }
        copy.isFirstInSection = isFirstInSection
        copy.isLastInSection  = isLastInSection
        return copy
    }
    
}
