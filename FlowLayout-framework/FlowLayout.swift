import UIKit
import os.log

open class FlowLayout: UICollectionViewFlowLayout {

    /// Here you can configure the behaviour of your global header.
    ///
    /// In order to add a global header to your view, ensure you return a `height > 0` from `FlowLayoutDelegate`
    ///
    ///     @objc optional func heightForGlobalHeader(in collectionView: UICollectionView,
    ///                                     layout collectionViewLayout: UICollectionViewLayout) -> CGFloat
    open var globalHeaderConfiguration: GlobalElementConfiguration = .init()

    /// Here you can configure the behaviour of your global footer.
    ///
    /// In order to add a global footer to your view, ensure you return a height > 0 from FlowLayoutDelegate
    ///
    ///     @objc optional func heightForGlobalFooter(in collectionView: UICollectionView,
    ///                                     layout collectionViewLayout: UICollectionViewLayout) -> CGFloat
    open var globalFooterConfiguration: GlobalElementConfiguration = .init()

    private var cachedGlobalHeaderSize: CGSize = .zero
    private var cachedGlobalFooterSize: CGSize = .zero
    
    internal var cachedGlobalHeaderAttributes: FlowLayoutAttributes?
    internal var cachedGlobalFooterAttributes: FlowLayoutAttributes?
    
    internal var cachedBackgroundAttributes: [Int: FlowLayoutAttributes] = [:]
    
    // MARK: - Invalidation
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if cachedGlobalHeaderAttributes != nil, globalHeaderConfiguration.pinsToBounds { return true }
        if cachedGlobalFooterAttributes != nil, globalFooterConfiguration.pinsToBounds { return true }
        if sectionHeadersPinToVisibleBounds { return true }
        if sectionFootersPinToVisibleBounds { return true }
        return false
    }
    
    open override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        guard let context = super.invalidationContext(forBoundsChange: newBounds) as? FlowLayoutInvalidationContext else {
            fatalError("Expected: \(FlowLayoutInvalidationContext.self)")
        }
        
        guard let collectionView = collectionView else { return context }
        
        // if the width has changed, invalidate the metrics
        if collectionView.bounds.width != newBounds.width {
            context.invalidateFlowLayoutDelegateMetrics = true
            context.invalidateGlobalHeaderMetrics = true
            context.invalidateGlobalFooterMetrics = true
            context.invalidateBackgrounds = true
        }
        
        // if we don't have cached attributes and either the height has changed or we need to pin, invalidate the attributes
        if cachedGlobalHeaderSize != .zero,
            globalHeaderConfiguration.pinsToBounds,
            collectionView.bounds.width == newBounds.width,
            collectionView.bounds.minY != newBounds.minY {
            context.invalidateGlobalHeaderLayoutAttributes = true
        }
        
        // if we don't have cached attributes and either the width has changed or we need to pin, invalidate the attributes
        if cachedGlobalFooterSize != .zero,
            globalFooterConfiguration.pinsToBounds,
            collectionView.bounds.width == newBounds.width,
            collectionView.bounds.maxY != newBounds.maxY {
            context.invalidateGlobalFooterLayoutAttributes = true
        }
        
        return context
    }
    
    open override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        guard let collectionView = collectionView else { return }

        guard let context = context as? FlowLayoutInvalidationContext else {
            fatalError("Expected: \(FlowLayoutInvalidationContext.self)")
        }
        
        super.invalidateLayout(with: context)

        if context.invalidateEverything {
            cachedGlobalHeaderSize = .zero
            cachedGlobalFooterSize = .zero
            cachedGlobalHeaderAttributes = nil
            cachedGlobalFooterAttributes = nil
            cachedBackgroundAttributes.removeAll()
        }
        
        if context.invalidateGlobalHeaderLayoutAttributes {
            cachedGlobalHeaderAttributes = nil
        }
        
        if context.invalidateGlobalFooterLayoutAttributes {
            cachedGlobalFooterAttributes = nil
        }
        
        if context.invalidateGlobalHeaderMetrics {
            cachedGlobalHeaderSize = .zero
        }
        
        if context.invalidateGlobalFooterMetrics {
            cachedGlobalFooterSize = .zero
        }

        if context.invalidateBackgrounds
            || context.invalidateFlowLayoutDelegateMetrics
            || context.invalidateDataSourceCounts {
            cachedBackgroundAttributes.removeAll()
        }
        
        // if a section has been invalidated in any way, we need to invalidate all backgrounds after (and including) that section
        if let section = Array(context.invalidatedSections).sorted().first {
            for index in 0..<(collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0) {
                cachedBackgroundAttributes[index] = nil
            }
        }
    }
    
    open override var collectionViewContentSize: CGSize {
        var contentSize = super.collectionViewContentSize
        contentSize.height += cachedGlobalHeaderAttributes?.size.height ?? 0
        contentSize.height += cachedGlobalFooterAttributes?.size.height ?? 0
        return contentSize
    }
    
    // MARK: - Prepare

    open override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }

        if cachedGlobalHeaderSize == .zero {
            cachedGlobalHeaderSize = sizeForGlobalHeader
        }

        if cachedGlobalHeaderSize != .zero, cachedGlobalHeaderAttributes == nil {
            cachedGlobalHeaderAttributes = FlowLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindGlobalHeader, with: UICollectionView.globalElementIndexPath)
            cachedGlobalHeaderAttributes?.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: cachedGlobalHeaderSize.height)
        }
        
        if cachedGlobalFooterSize == .zero {
            cachedGlobalFooterSize = sizeForGlobalFooter
        }
        
        if cachedGlobalFooterSize != .zero, cachedGlobalFooterAttributes == nil {
            cachedGlobalFooterAttributes = FlowLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindGlobalFooter, with: UICollectionView.globalElementIndexPath)
            let maxY = max(collectionView.bounds.maxY, collectionViewContentSize.height) - cachedGlobalFooterSize.height
            cachedGlobalFooterAttributes?.frame = CGRect(x: 0, y: maxY, width: collectionView.bounds.width, height: cachedGlobalFooterSize.height)
        }
        
        let sectionCount = collectionView.dataSource?.numberOfSections?(in: collectionView) ?? 0
        
        for section in 0..<sectionCount {
            guard cachedBackgroundAttributes[section] == nil else { continue }
            
            guard let style = (collectionView.delegate as? FlowLayoutDelegate)?
                .backgroundLayoutStyle?(in: collectionView, forSectionAt: section),
                style != .none else { continue }
            
            let itemCount = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0
            let insets = (collectionView.delegate as? FlowLayoutDelegate)?
                .backgroundLayoutInsets?(in: collectionView, forSectionAt: section) ?? .zero
            
            cachedBackgroundAttributes[section] = backgroundAttributes(section: section, numberOfItems: itemCount, style: style, insets: insets)
        }
    }
    
    // MARK: - Attributes
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let rect = rect.insetBy(dx: 0, dy: -(cachedGlobalHeaderSize.height + cachedGlobalFooterSize.height))
        var originalAttributes = super.layoutAttributesForElements(in: rect) ?? []
        
        if let attributes = copy(of: cachedGlobalHeaderAttributes).map({ adjustedAttributes(for: $0) }),
            attributes.frame.intersects(rect) {
            originalAttributes.append(attributes)
        }
        
        if let attributes = copy(of: cachedGlobalFooterAttributes).map({ adjustedAttributes(for: $0) }),
            attributes.frame.intersects(rect) {
            originalAttributes.append(attributes)
        }
        
        let attributes = cachedBackgroundAttributes.values
            .filter({ $0.frame.intersects(rect) })
        
        originalAttributes.append(contentsOf: attributes)
        
        return adjustedAttributes(for: copy(of: originalAttributes) ?? [])
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attributes: FlowLayoutAttributes?
        
        switch elementKind {
        case UICollectionView.elementKindGlobalHeader:
            attributes = cachedGlobalHeaderAttributes
        case UICollectionView.elementKindGlobalFooter:
            attributes = cachedGlobalFooterAttributes
        case UICollectionView.elementKindBackground:
            attributes = cachedBackgroundAttributes[indexPath.section]
        default:
            attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath) as? FlowLayoutAttributes
        }
        
        return copy(of: attributes).map { adjustedAttributes(for: $0) }
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
        return copy(of: attributes).map { adjustedAttributes(for: $0) }
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
