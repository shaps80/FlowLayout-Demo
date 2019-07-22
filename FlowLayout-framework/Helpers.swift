import UIKit

public extension FlowLayout {
    
    var sizeForGlobalHeader: CGSize {
        guard let collectionView = collectionView else { return .zero }
        let height = (collectionView.delegate as? FlowLayoutDelegate)?
            .heightForGlobalHeader?(in: collectionView, layout: self) ?? 0
        return height == 0 ? .zero : CGSize(width: collectionView.bounds.width, height: height)
    }
    
    var sizeForGlobalFooter: CGSize {
        guard let collectionView = collectionView else { return .zero }
        let height = (collectionView.delegate as? FlowLayoutDelegate)?
            .heightForGlobalFooter?(in: collectionView, layout: self) ?? 0
        return height == 0 ? .zero : CGSize(width: collectionView.bounds.width, height: height)
    }
    
    func insets(for section: Int) -> UIEdgeInsets {
        guard let collectionView = collectionView,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else {
                return .zero
        }
        
        return delegate.collectionView?(collectionView, layout: self, insetForSectionAt: section)
            ?? sectionInset
    }
    
    func interitemSpacing(for section: Int) -> CGFloat {
        guard let collectionView = collectionView,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else {
                return .zero
        }
        
        return delegate.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section)
            ?? minimumInteritemSpacing
    }
    
    func lineSpacing(for section: Int) -> CGFloat {
        guard let collectionView = collectionView,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else {
                return .zero
        }
        
        return delegate.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: section)
            ?? minimumLineSpacing
    }
    
}
