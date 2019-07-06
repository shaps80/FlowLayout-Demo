import UIKit
import os.log

open class FlowLayout: BaseFlowLayout {
        
    open override class var layoutAttributesClass: AnyClass {
        return FlowLayoutAttributes.self
    }
    
    open override class var invalidationContextClass: AnyClass {
        return FlowLayoutInvalidationContext.self
    }
    
    open var globalElements: [FlowLayoutGlobalElement] = [] {
        didSet {
            let context = FlowLayoutInvalidationContext()
            context.invalidateGlobalHeader = true
            context.invalidateGlobalFooter = true
            invalidateLayout(with: context)
        }
    }
    
    // MARK: - Invalidation
    
    open override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        guard let context = context as? FlowLayoutInvalidationContext else {
            fatalError("Expected: \(FlowLayoutInvalidationContext.self)")
        }
        
        super.invalidateLayout(with: context)
        print("\(#function)\n\(context.debugDescription)")
    }
    
    open override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        print("\(#function) old: \(collectionView?.bounds ?? .zero) new: \(newBounds)")
        
        guard let context = super.invalidationContext(forBoundsChange: newBounds) as? UICollectionViewFlowLayoutInvalidationContext else {
            fatalError("Expected: \(UICollectionViewFlowLayoutInvalidationContext.self)")
        }

        guard let collectionView = collectionView else { return context }
        
        if collectionView.bounds.size != newBounds.size {
            context.invalidateFlowLayoutDelegateMetrics = true
        }
        
        return context
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        print("\(#function) old: \(collectionView?.bounds ?? .zero) new: \(newBounds)")
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
    
    // MARK: - Supplementary IndexPath Tracking
    
    open override func indexPathsToInsertForSupplementaryView(ofKind elementKind: String) -> [IndexPath] {
        print("\(#function) \(elementKind)")
        return super.indexPathsToInsertForSupplementaryView(ofKind: elementKind)
    }
    
    open override func indexPathsToDeleteForSupplementaryView(ofKind elementKind: String) -> [IndexPath] {
        print("\(#function) \(elementKind)")
        return super.indexPathsToDeleteForSupplementaryView(ofKind: elementKind)
    }
    
    // MARK: - Prepare
    
    open override func prepare() {
        super.prepare()
        print("\(#function)")
    }
    
    open override func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
        super.prepare(forAnimatedBoundsChange: oldBounds)
        print("\(#function) before: \(oldBounds) after: \(collectionView?.bounds ?? .zero)")
    }
    
    open override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        print("\(#function)")
    }
    
    // MARK: - Attributes
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        print("\(#function) \(rect)")
        return super.layoutAttributesForElements(in: rect)
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("\(#function) \(elementKind) \(indexPath)")
        return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("\(#function) \(indexPath)")
        return super.layoutAttributesForItem(at: indexPath)
    }
    
    // MARK: - Target Offset
    
    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        print("\(#function) \(proposedContentOffset)")
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
    
    // MARK: - Animation
    
    open override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("\(#function) \(itemIndexPath)")
        return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
    }
    
    open override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("\(#function) \(itemIndexPath)")
        return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
    }
    
    open override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("\(#function) \(elementKind) \(elementIndexPath)")
        return super.initialLayoutAttributesForAppearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath)
    }
    
    open override func finalLayoutAttributesForDisappearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("\(#function) \(elementKind) \(elementIndexPath)")
        return super.finalLayoutAttributesForDisappearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath)
    }
    
    // MARK: - Finalize
    
    open override func finalizeAnimatedBoundsChange() {
        super.finalizeAnimatedBoundsChange()
        print("\(#function)")
    }
    
    open override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        print("\(#function)")
    }
    
}
