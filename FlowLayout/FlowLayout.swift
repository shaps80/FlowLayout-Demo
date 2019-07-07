import UIKit
import os.log

open class FlowLayout: UICollectionViewFlowLayout {

    open var globalHeaderConfiguration: GlobalElementConfiguration = .init()
    open var globalFooterConfiguration: GlobalElementConfiguration = .init()
    
    private var previousCachedGlobalHeaderSize: CGSize = .zero
    private var previousCachedGlobalFooterSize: CGSize = .zero
    
    private var cachedGlobalHeaderSize: CGSize = .zero
    private var cachedGlobalFooterSize: CGSize = .zero
    
    private var globalHeaderUpdate: UICollectionViewUpdateItem.Action = .none
    private var globalFooterUpdate: UICollectionViewUpdateItem.Action = .none
    
    internal var cachedGlobalHeaderAttributes: FlowLayoutAttributes?
    internal var cachedGlobalFooterAttributes: FlowLayoutAttributes?
    
    // MARK: - Invalidation
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if cachedGlobalHeaderAttributes != nil, globalHeaderConfiguration.pinsToBounds {
            print("\(#function) global header is pinned")
            return true
        }
        
        if cachedGlobalFooterAttributes != nil, globalFooterConfiguration.pinsToBounds {
            print("\(#function) global footer is pinned")
            return true
        }
        
        if sectionHeadersPinToVisibleBounds {
            print("\(#function) section headers are pinned")
            return true
        }
        
        if sectionFootersPinToVisibleBounds {
            print("\(#function) section foooters are pinned")
            return true
        }

        return false
    }
    
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
            let oldSize = cachedGlobalHeaderSize
            let newSize = sizeForGlobalHeader
            
            if !context.invalidateEverything {
                if oldSize == newSize {
                    globalHeaderUpdate = .none
                } else if oldSize == .zero, newSize != .zero {
                    globalHeaderUpdate = .insert
                } else if oldSize != .zero, newSize == .zero {
                    globalHeaderUpdate = .delete
                } else {
                    globalHeaderUpdate = .reload
                }
            } else {
                globalHeaderUpdate = .none
            }

            cachedGlobalHeaderSize = newSize
            cachedGlobalHeaderAttributes = nil
        }
        
        if context.invalidateGlobalFooter {
            let oldSize = cachedGlobalFooterSize
            let newSize = sizeForGlobalFooter
            
            if !context.invalidateEverything {
                if oldSize == newSize {
                    globalFooterUpdate = .none
                } else if oldSize == .zero, newSize != .zero {
                    globalFooterUpdate = .insert
                } else if oldSize != .zero, newSize == .zero {
                    globalFooterUpdate = .delete
                } else {
                    globalFooterUpdate = .reload
                }
            } else {
                globalFooterUpdate = .none
            }
            
            cachedGlobalFooterSize = newSize
            cachedGlobalFooterAttributes = nil
        }
        
        print("\(#function)\n\(context.debugDescription)")
    }
    
    open override var collectionViewContentSize: CGSize {
        var contentSize = super.collectionViewContentSize
        contentSize.height += cachedGlobalHeaderAttributes?.size.height ?? 0
        contentSize.height += cachedGlobalFooterAttributes?.size.height ?? 0
        print("\(#function) \(contentSize)")
        return contentSize
    }
    
    // MARK: - Supplementary IndexPath Tracking
    
    open override func indexPathsToInsertForSupplementaryView(ofKind elementKind: String) -> [IndexPath] {
        var indexPaths = super.indexPathsToInsertForSupplementaryView(ofKind: elementKind)
        
        if elementKind == UICollectionView.elementKindGlobalHeader, globalHeaderUpdate == .insert {
            print("\(#function) \(elementKind) \(globalHeaderUpdate)")
            indexPaths.append(UICollectionView.globalElementIndexPath)
        }
        
        if elementKind == UICollectionView.elementKindGlobalFooter, globalFooterUpdate == .insert {
            print("\(#function) \(elementKind) \(globalFooterUpdate)")
            indexPaths.append(UICollectionView.globalElementIndexPath)
        }
        
        return indexPaths
    }
    
    open override func indexPathsToDeleteForSupplementaryView(ofKind elementKind: String) -> [IndexPath] {
        var indexPaths = super.indexPathsToDeleteForSupplementaryView(ofKind: elementKind)
        
        if elementKind == UICollectionView.elementKindGlobalHeader, globalHeaderUpdate == .delete {
            print("\(#function) \(elementKind) \(globalHeaderUpdate)")
            indexPaths.append(UICollectionView.globalElementIndexPath)
        }
        
        if elementKind == UICollectionView.elementKindGlobalFooter, globalFooterUpdate == .delete {
            print("\(#function) \(elementKind) \(globalFooterUpdate)")
            indexPaths.append(UICollectionView.globalElementIndexPath)
        }
        
        return indexPaths
    }
    
    // MARK: - Prepare
    
    open override func prepare() {
        super.prepare()
        print("\(#function)")
        
        guard let collectionView = collectionView else { return }
        
        let globalHeaderSize = cachedGlobalHeaderSize
        
        if globalHeaderSize != .zero {
            cachedGlobalHeaderAttributes = FlowLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindGlobalHeader, with: UICollectionView.globalElementIndexPath)
            cachedGlobalHeaderAttributes?.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: globalHeaderSize.height)
        }
        
        let globalFooterSize = cachedGlobalFooterSize
        
        if globalFooterSize != .zero {
            cachedGlobalFooterAttributes = FlowLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindGlobalFooter, with: UICollectionView.globalElementIndexPath)
            let maxY = max(collectionView.bounds.maxY, collectionViewContentSize.height) - globalFooterSize.height
            cachedGlobalFooterAttributes?.frame = CGRect(x: 0, y: maxY, width: collectionView.bounds.width, height: globalFooterSize.height)
        }
    }
    
    open override func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
        super.prepare(forAnimatedBoundsChange: oldBounds)
        print("\(#function) before: \(oldBounds) after: \(collectionView?.bounds ?? .zero)")
    }
    
    open override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        print("\(#function) \(updateItems)")
    }
    
    // MARK: - Attributes
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var originalAttributes = super.layoutAttributesForElements(in: rect) ?? []
        
        if let attributes = copy(of: cachedGlobalHeaderAttributes).map({ adjustedAttributes(for: $0) }),
            attributes.frame.intersects(collectionView?.bounds ?? rect) {
            originalAttributes.append(attributes)
        }
        
        if let attributes = copy(of: cachedGlobalFooterAttributes).map({ adjustedAttributes(for: $0) }),
            attributes.frame.intersects(collectionView?.bounds ?? rect) {
            originalAttributes.append(attributes)
        }
        
        print("\(#function)\n---\n\(originalAttributes.compactMap { $0.representedElementKind })\n---\n")
        return adjustedAttributes(for: copy(of: originalAttributes) ?? [])
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
            attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath) as? FlowLayoutAttributes
        }
        
        return copy(of: attributes).map { adjustedAttributes(for: $0) }
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("\(#function) \(indexPath)")
        guard let attributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
        return copy(of: attributes).map { adjustedAttributes(for: $0) }
    }
    
    // MARK: - Target Offset
    
    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        print("\(#function) \(proposedContentOffset)")
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
    
    // MARK: - Animation
    
    open override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("\(#function) \(elementKind) \(elementIndexPath)")
        
        let attributes = copy(of: super.finalLayoutAttributesForDisappearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath))
        
        switch elementKind {
        case UICollectionView.elementKindGlobalHeader where globalHeaderUpdate == .insert:
            attributes?.alpha = 0
            attributes?.frame.origin.y = (collectionView?.bounds.minY ?? 0) - (attributes?.size.height ?? 0)
            return attributes
        case UICollectionView.elementKindGlobalFooter where globalFooterUpdate == .insert:
            attributes?.alpha = 0
            attributes?.frame.origin.y = (collectionView?.bounds.maxY ?? 0) + (attributes?.size.height ?? 0)
            return attributes
        default:
            break
        }
        
        return attributes
    }
    
    open override func finalLayoutAttributesForDisappearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("\(#function) \(elementKind) \(elementIndexPath)")
        
        let attributes = copy(of: super.finalLayoutAttributesForDisappearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath))
        
        switch elementKind {
        case UICollectionView.elementKindGlobalHeader where globalHeaderUpdate == .delete:
            attributes?.alpha = 0
            attributes?.frame.origin.y = (collectionView?.bounds.minY ?? 0) - (attributes?.size.height ?? 0)
            return attributes
        case UICollectionView.elementKindGlobalFooter where globalFooterUpdate == .delete:
            attributes?.alpha = 0
            attributes?.frame.origin.y = (collectionView?.bounds.maxY ?? 0) + (attributes?.size.height ?? 0)
            return attributes
        default:
            break
        }
        
        return attributes
    }
    
    // MARK: - Finalize
    
    open override func finalizeAnimatedBoundsChange() {
        super.finalizeAnimatedBoundsChange()
        print("\(#function)")
    }
    
    open override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        print("\(#function)")
        
        globalHeaderUpdate = .none
        globalFooterUpdate = .none
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
