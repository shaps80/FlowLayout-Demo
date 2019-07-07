import UIKit
import os.log

open class FlowLayout: UICollectionViewFlowLayout {

    open var globalHeaderConfiguration: GlobalElementConfiguration = .init()
    open var globalFooterConfiguration: GlobalElementConfiguration = .init()
    
    private var cachedGlobalHeaderAttributes: FlowLayoutAttributes?
    private var cachedGlobalFooterAttributes: FlowLayoutAttributes?
    
    // MARK: - Invalidation
    
    open override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        print("\(#function) old: \(collectionView?.bounds ?? .zero) new: \(newBounds)")
        
        guard let context = super.invalidationContext(forBoundsChange: newBounds) as? FlowLayoutInvalidationContext else {
            fatalError("Expected: \(FlowLayoutInvalidationContext.self)")
        }

        guard let collectionView = collectionView else { return context }
        
        if collectionView.bounds.size != newBounds.size {
            context.invalidateFlowLayoutDelegateMetrics = true
        }
        
        if cachedGlobalHeaderAttributes != nil, globalHeaderConfiguration.pinsToBounds {
            context.invalidateGlobalHeader = true
        }
        
        if cachedGlobalFooterAttributes != nil, globalFooterConfiguration.pinsToBounds {
            context.invalidateGlobalFooter = true
        }
        
        return context
    }
    
    open override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        guard let context = context as? FlowLayoutInvalidationContext else {
            fatalError("Expected: \(FlowLayoutInvalidationContext.self)")
        }
        
        super.invalidateLayout(with: context)
        
        if context.invalidateGlobalHeader {
            cachedGlobalHeaderAttributes = nil
        }
        
        if context.invalidateGlobalFooter {
            cachedGlobalFooterAttributes = nil
        }
        
        print("\(#function)\n\(context.debugDescription)")
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        print("\(#function) old: \(collectionView?.bounds ?? .zero) new: \(newBounds)")
        if cachedGlobalHeaderAttributes != nil, globalHeaderConfiguration.pinsToBounds { return true }
        if cachedGlobalFooterAttributes != nil, globalFooterConfiguration.pinsToBounds { return true }
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
    
    open override var collectionViewContentSize: CGSize {
        var contentSize = super.collectionViewContentSize
        contentSize.height += cachedGlobalHeaderAttributes?.size.height ?? 0
        // footer: need to add footer here
        return contentSize
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
        
        guard let collectionView = collectionView else { return }
        
        let globalHeaderSize = sizeForGlobalHeader
        
        if globalHeaderSize != .zero {
            cachedGlobalHeaderAttributes = FlowLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindGlobalHeader, with: UICollectionView.globalElementIndexPath)
            cachedGlobalHeaderAttributes?.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: globalHeaderSize.height)
        }
        
        let globalFooterSize = sizeForGlobalFooter
        
        if globalFooterSize != .zero {
            cachedGlobalFooterAttributes = FlowLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindGlobalFooter, with: UICollectionView.globalElementIndexPath)
            let maxY = max(collectionView.bounds.maxY, collectionViewContentSize.height)
            cachedGlobalFooterAttributes?.frame = CGRect(x: 0, y: maxY, width: collectionView.bounds.width, height: globalFooterSize.height)
        }
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
        var originalAttributes = copy(of: super.layoutAttributesForElements(in: rect))
        
        if let attributes = cachedGlobalHeaderAttributes, attributes.frame.intersects(rect) {
            originalAttributes?.append(attributes)
        }
        
        if let attributes = cachedGlobalFooterAttributes, attributes.frame.intersects(rect) {
            originalAttributes?.append(attributes)
        }
        
        return adjustedAttributes(for: originalAttributes ?? [])
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("\(#function) \(elementKind) \(indexPath)")
        
        let attributes: FlowLayoutAttributes?
        
        switch elementKind {
        case UICollectionView.elementKindGlobalHeader:
            attributes = cachedGlobalHeaderAttributes
        case UICollectionView.elementKindGlobalFooter:
            attributes = cachedGlobalFooterAttributes
        default:
            guard let originalAttributes = copy(of: super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)) else { return nil }
            attributes = originalAttributes
        }
        
        return attributes.map { adjustedAttributes(for: $0) }
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("\(#function) \(indexPath)")
        guard let attributes = copy(of: super.layoutAttributesForItem(at: indexPath)) else { return nil }
        return adjustedAttributes(for: attributes)
    }
    
    private func adjustedAttributes(for attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes] {
        return attributes.map { adjustedAttributes(for: $0) }
    }
    
    private func adjustedAttributes(for attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        switch attributes.representedElementKind {
        case UICollectionView.elementKindGlobalHeader:
            return attributes
        case UICollectionView.elementKindGlobalFooter:
            return attributes
        default:
            attributes.frame.origin.y += cachedGlobalHeaderAttributes?.size.height ?? 0
            return attributes
        }
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
    
    // MARK: - Override class types
    
    open override class var layoutAttributesClass: AnyClass {
        return FlowLayoutAttributes.self
    }
    
    open override class var invalidationContextClass: AnyClass {
        return FlowLayoutInvalidationContext.self
    }
    
}

// MARK: - Helpers
private extension FlowLayout {
    
    func copy(of attributes: UICollectionViewLayoutAttributes?) -> FlowLayoutAttributes? {
        return attributes?.copy() as? FlowLayoutAttributes
    }
    
    func copy(of attributes: [UICollectionViewLayoutAttributes]?) -> [FlowLayoutAttributes]? {
        guard let attributes = attributes else { return nil }
        return NSArray(array: attributes, copyItems: true) as? [FlowLayoutAttributes]
    }
    
}
