import UIKit

/// Represents a base implementation that provides some conveniences as well as access to the collectionView and layout instances.
open class FlowLayoutElement: NSObject {
    
    internal unowned var layout: FlowLayout!
    
    internal var collectionView: UICollectionView {
        return layout.collectionView!
    }
    
    public override init() {
        super.init()
    }
    
    /// The layout will ask this element if it requires invalidation for a bounds change.
    /// - Parameter newBounds: The new bounds
    open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
    
    /// The layout will ask this element for its attributes inside the specified rect
    /// - Parameter rect: The rect represented by layoutAttributesForElements(in:)
    open func attributes(in rect: CGRect) -> UICollectionViewLayoutAttributes? {
        return nil
    }
    
    /// The layout will ask this element for a copy of any adjusted attributes for all non-managed elements including cells, headers and footers.
    ///
    /// Generally you shouldn't need to implement this.
    /// If you override this method be careful to handle the copying yourself since this method
    /// and ensure you call through to the methods below.
    ///
    /// - Parameter attributes: The original attributes
    internal func adjustedAttributes(for attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let originalAttributes = attributes // can't return in the guard if we don't do this
        guard let attributes = attributes.copy() as? FlowLayoutAttributes else { return originalAttributes }
        
        switch attributes.representedElementCategory {
        case .cell:
            return adjustedAttributes(forCell: attributes)
        case .supplementaryView:
            return adjustedAttributes(forSupplementary: attributes)
        case .decorationView:
            return adjustedAttributes(forDecoration: attributes)
        default:
            return attributes
        }
    }
    
    /// The layout will ask this element for any adjusted attributes for the specified cell
    /// - Parameter attributesCopy: A copy of the original attributes
    open func adjustedAttributes(forCell attributesCopy: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return attributesCopy
    }
    
    /// The layout will ask this element for any adjusted attributes for the specified supplmentary view
    /// - Parameter attributesCopy: A copy of the original attributes
    open func adjustedAttributes(forSupplementary attributesCopy: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return attributesCopy
    }
    
    /// The layout will ask this element for any adjusted attributes for the specified decoration view
    /// - Parameter attributesCopy: A copy of the original attributes
    open func adjustedAttributes(forDecoration attributesCopy: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return attributesCopy
    }
    
}
