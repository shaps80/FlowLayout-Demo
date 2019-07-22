import UIKit

/// A UICollectionViewFlowLayoutInvalidationContext subclass that adds support for global headers and footers.
///
/// This class should be used with `Composed.FlowLayout`
public final class FlowLayoutInvalidationContext: UICollectionViewFlowLayoutInvalidationContext {
    
    // todo: update these properies ars below
    
    private var _invalidateGlobalHeaderLayoutAttributes: Bool = false
    /// Invalidates just the position of the global header
    public var invalidateGlobalHeaderLayoutAttributes: Bool {
        get { return _invalidateGlobalHeaderLayoutAttributes }
        set {
            guard newValue else { return }
            _invalidateGlobalHeaderLayoutAttributes = newValue
        }
    }
    
    private var _invalidateGlobalFooterLayoutAttributes: Bool = false
    /// Invalidates just the position of the global footer
    public var invalidateGlobalFooterLayoutAttributes: Bool {
        get { return _invalidateGlobalFooterLayoutAttributes }
        set {
            guard newValue else { return }
            _invalidateGlobalFooterLayoutAttributes = newValue
        }
    }
    
    private var _invalidateGlobalHeaderMetrics: Bool = false
    /// Invalidates the size and position of the global header
    public var invalidateGlobalHeaderMetrics: Bool {
        get { return _invalidateGlobalHeaderMetrics }
        set {
            guard newValue else { return }
            _invalidateGlobalHeaderMetrics = newValue
            _invalidateGlobalHeaderLayoutAttributes = newValue
        }
    }
    
    private var _invalidateGlobalFooterMetrics: Bool = false
    /// Invalidates the size and position of the global footer
    public var invalidateGlobalFooterMetrics: Bool {
        get { return _invalidateGlobalFooterMetrics }
        set {
            guard newValue else { return }
            _invalidateGlobalFooterMetrics = newValue
            _invalidateGlobalFooterLayoutAttributes = newValue
        }
    }
    
    private var _invalidateGlobalHeader: Bool = false
    /// Invalidate all cached values for the global header
    public var invalidateGlobalHeader: Bool {
        get { return _invalidateGlobalHeader }
        set {
            guard newValue else { return }
            _invalidateGlobalHeader = newValue
            _invalidateGlobalHeaderMetrics = newValue
            _invalidateGlobalHeaderLayoutAttributes = newValue
            invalidateSupplementaryElements(ofKind: UICollectionView.elementKindGlobalHeader, at: [UICollectionView.globalElementIndexPath])
        }
    }
    
    private var _invalidateGlobalFooter: Bool = false
    /// Invalidate all cached values for the global footer
    public var invalidateGlobalFooter: Bool {
        get { return _invalidateGlobalFooter }
        set {
            guard newValue else { return }
            _invalidateGlobalFooter = newValue
            _invalidateGlobalFooterMetrics = newValue
            _invalidateGlobalFooterLayoutAttributes = newValue
            invalidateSupplementaryElements(ofKind: UICollectionView.elementKindGlobalFooter, at: [UICollectionView.globalElementIndexPath])
        }
    }
    
    /// Invalidates the background for the specified section
    /// - Parameter section: The section to invalidate
    public func invalidateBackground(for section: Int) {
        invalidateSupplementaryElements(ofKind: UICollectionView.elementKindBackground, at: [IndexPath(item: 0, section: section)])
    }
    
    
    private var _invalidateBackgrounds: Bool = false
    public var invalidateBackgrounds: Bool {
        get { return _invalidateBackgrounds }
        set {
            guard newValue else { return }
            _invalidateBackgrounds = newValue
        }
    }
    
    internal var invalidatedSections: Set<Int> {
        let headers = invalidatedSupplementaryIndexPaths?[UICollectionView.elementKindSectionHeader]
            .map { $0 }?
            .map { $0.section } ?? []
        
        let footers = invalidatedSupplementaryIndexPaths?[UICollectionView.elementKindSectionFooter]
            .map { $0 }?
            .map { $0.section } ?? []
        
        let backgrounds = invalidatedSupplementaryIndexPaths?[UICollectionView.elementKindBackground]
            .map { $0 }?
            .map { $0.section } ?? []
        
        let items = invalidatedItemIndexPaths?.map { $0.section } ?? []
        return Set(headers + footers + items + backgrounds)
    }
    
}

extension FlowLayoutInvalidationContext {
    
    public override var debugDescription: String {
        return """
        ---
        Everything: \(invalidateEverything)
        DataSource: \(invalidateDataSourceCounts)
        Global header: \(invalidateGlobalHeader)
        Global header metrics: \(invalidateGlobalHeaderMetrics)
        Global header attributes: \(invalidateGlobalHeaderLayoutAttributes)
        Global footer: \(invalidateGlobalFooter)
        Global footer metrics: \(invalidateGlobalFooterMetrics)
        Global footer attributes: \(invalidateGlobalFooterLayoutAttributes)
        All Backgrounds: \(invalidateBackgrounds)
        All Attributes: \(invalidateFlowLayoutAttributes)
        All Metrics: \(invalidateFlowLayoutDelegateMetrics)
        Items: \(invalidatedItemIndexPaths ?? [])
        Supplementary: \(invalidatedSupplementaryIndexPaths ?? [:])
        ---
        """
    }
    
}
