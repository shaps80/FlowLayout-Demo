import UIKit

open class FlowLayoutGlobalElement: FlowLayoutElement {
    
    open var configuration: GlobalElementConfiguration = .init()
    private var headerHeight: CGFloat = 44
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return configuration.pinsToBounds || configuration.pinsToContent
    }
   
    open override func attributes(in rect: CGRect) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindGlobalHeader,
                                                          with: UICollectionView.globalElementIndexPath)
        let minY = configuration.pinsToBounds ? collectionView.contentOffset.y : 0
        attributes.frame = CGRect(x: 0, y: minY, width: collectionView.bounds.width, height: headerHeight)
        return attributes
    }
    
    open override func adjustedAttributes(forCell attributesCopy: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        attributesCopy.frame.origin.y += headerHeight + configuration.inset
        return attributesCopy
    }
    
    open override func adjustedAttributes(forSupplementary attributesCopy: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        attributesCopy.frame.origin.y += headerHeight + configuration.inset
        return attributesCopy
    }
    
}
