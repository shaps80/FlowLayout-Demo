import UIKit

// MARK: - Adjustments

extension FlowLayout {
    
    var adjustedOrigin: CGPoint {
        guard cachedGlobalHeaderAttributes != nil else { return .zero }
        var origin = adjustedGlobalHeaderOrigin
        origin.y += adjustedGlobalHeaderSize.height + globalHeaderConfiguration.inset
        return origin
    }
    
    var additionalContentInset: CGFloat {
        guard cachedGlobalHeaderAttributes != nil, let collectionView = collectionView else { return 0 }
        guard globalHeaderConfiguration.layoutFromSafeArea else { return 0 }
        
        let safeAreaAdjustment = collectionView.adjustedContentInset.top - collectionView.contentInset.top
        
        switch collectionView.contentInsetAdjustmentBehavior {
        case .never:
            let isTopBarHidden = safeAreaAdjustment != collectionView.safeAreaInsets.top
            
            if isTopBarHidden {
                return collectionView.safeAreaInsets.top
            } else {
                return collectionView.adjustedContentInset.top
            }
        default:
            return safeAreaAdjustment
        }
    }
    
    func adjustedAttributes(for attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = attributes
        
        switch attributes.representedElementKind {
        case UICollectionView.elementKindGlobalHeader:
            attributes.frame.origin = adjustedGlobalHeaderOrigin
            attributes.frame.size = adjustedGlobalHeaderSize
            attributes.zIndex = UICollectionView.globalHeaderZIndex
            
            if globalHeaderConfiguration.pinsToBounds {
                let offset = adjustedHeaderContentOffset
                
                if globalHeaderConfiguration.prefersFollowContent, offset.y > 0 {
                    // do nothing
                } else {
                    attributes.frame.origin.y += offset.y
                }
                
                if globalHeaderConfiguration.pinsToContent, offset.y < 0 {
                    attributes.frame.size.height -= offset.y
                }
            }
        case UICollectionView.elementKindGlobalFooter:
            attributes.frame.origin = adjustedGlobalFooterOrigin
            attributes.frame.size = adjustedGlobalFooterSize
            attributes.zIndex = UICollectionView.globalFooterZIndex
            
            if globalFooterConfiguration.pinsToBounds {
                let offset = adjustedFooterContentOffset
                
                if globalFooterConfiguration.prefersFollowContent, offset.y < 0 {
                    // do nothing
                } else {
                    attributes.frame.origin.y += offset.y
                }
                
                if globalFooterConfiguration.pinsToContent, offset.y > 0 {
                    attributes.frame.origin.y -= offset.y
                    attributes.frame.size.height += offset.y
                }
            }
        default:
            attributes.frame.origin.y += adjustedOrigin.y
        }
        
        return attributes
    }
    
    func adjustedAttributes(for attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes] {
        return attributes.map { adjustedAttributes(for: $0) }
    }
    
}

// MARK: - Global Header

extension FlowLayout {
    
    var adjustedGlobalHeaderOrigin: CGPoint {
        guard cachedGlobalHeaderAttributes != nil, let collectionView = collectionView else { return .zero }
        var adjustedOrigin = CGPoint.zero
        adjustedOrigin.y += additionalContentInset
        adjustedOrigin.y -= collectionView.adjustedContentInset.top
        return adjustedOrigin
    }
    
    var adjustedGlobalHeaderSize: CGSize {
        guard let attributes = cachedGlobalHeaderAttributes, let collectionView = collectionView else { return .zero }
        var adjustedSize = attributes.size
        adjustedSize.height += globalHeaderConfiguration.layoutFromSafeArea ? 0 : collectionView.safeAreaInsets.top
        return adjustedSize
    }
    
    var adjustedHeaderContentOffset: CGPoint {
        guard let collectionView = collectionView else { return .zero }
        var contentOffset = collectionView.contentOffset
        contentOffset.y += collectionView.adjustedContentInset.top
        return contentOffset
    }
    
}

// MARK: - Global Footer

extension FlowLayout {
    
    var adjustedGlobalFooterOrigin: CGPoint {
        guard let collectionView = collectionView else { return .zero }
        var adjustedOrigin = CGPoint.zero
        adjustedOrigin.y += collectionViewContentSize.height - adjustedGlobalFooterSize.height
        adjustedOrigin.y += !globalFooterConfiguration.layoutFromSafeArea ? collectionView.adjustedContentInset.bottom : 0
        return adjustedOrigin
    }
    
    var adjustedGlobalFooterSize: CGSize {
        guard let attributes = cachedGlobalFooterAttributes, let collectionView = collectionView else { return .zero }
        var adjustedSize = attributes.size
        adjustedSize.height += globalFooterConfiguration.layoutFromSafeArea ? 0 : collectionView.safeAreaInsets.bottom
        return adjustedSize
    }
    
    var adjustedFooterContentOffset: CGPoint {
        guard let collectionView = collectionView else { return .zero }
        var contentOffset = CGPoint(x: 0, y: collectionView.bounds.maxY - collectionViewContentSize.height)
        contentOffset.y -= collectionView.adjustedContentInset.bottom
        return contentOffset
    }
    
}
