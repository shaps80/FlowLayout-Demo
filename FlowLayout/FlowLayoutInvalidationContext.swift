import UIKit

/// A UICollectionViewFlowLayoutInvalidationContext subclass that adds support for global headers and footers.
///
/// This class should be used with `Composed.FlowLayout`
public final class FlowLayoutInvalidationContext: UICollectionViewFlowLayoutInvalidationContext {
    
    // todo: update these properies ars below
    
    private var _invalidateGlobalHeaderLayoutAttributes: Bool = false
    public var invalidateGlobalHeaderLayoutAttributes: Bool {
        get { return invalidateEverything ? true : _invalidateGlobalHeaderLayoutAttributes }
        set {
            guard newValue else { return }
            _invalidateGlobalHeaderLayoutAttributes = newValue
        }
    }
    
    private var _invalidateGlobalFooterLayoutAttributes: Bool = false
    public var invalidateGlobalFooterLayoutAttributes: Bool {
        get { return invalidateEverything ? true : _invalidateGlobalFooterLayoutAttributes }
        set {
            guard newValue else { return }
            _invalidateGlobalFooterLayoutAttributes = newValue
        }
    }
    
    private var _invalidateGlobalHeaderMetrics: Bool = false
    public var invalidateGlobalHeaderMetrics: Bool {
        get { return invalidateEverything ? true : _invalidateGlobalHeaderMetrics }
        set {
            guard newValue else { return }
            _invalidateGlobalHeaderMetrics = newValue
            _invalidateGlobalHeaderLayoutAttributes = newValue
        }
    }
    
    private var _invalidateGlobalFooterMetrics: Bool = false
    /// Invalidae the size of the footer only
    public var invalidateGlobalFooterMetrics: Bool {
        get { return invalidateEverything ? true : _invalidateGlobalFooterMetrics }
        set {
            guard newValue else { return }
            _invalidateGlobalFooterMetrics = newValue
            _invalidateGlobalFooterLayoutAttributes = newValue
        }
    }
    
    private var _invalidateGlobalHeader: Bool = false
    /// Invalidate the global header
    public var invalidateGlobalHeader: Bool {
        get { return invalidateEverything ? true : _invalidateGlobalHeader }
        set {
            guard newValue else { return }
            _invalidateGlobalHeader = newValue
            _invalidateGlobalHeaderMetrics = newValue
            _invalidateGlobalHeaderLayoutAttributes = newValue
        }
    }
    
    private var _invalidateGlobalFooter: Bool = false
    /// Invalidate the global footer
    public var invalidateGlobalFooter: Bool {
        get { return invalidateEverything ? true : _invalidateGlobalFooter }
        set {
            guard newValue else { return }
            _invalidateGlobalFooter = newValue
            _invalidateGlobalFooterMetrics = newValue
            _invalidateGlobalFooterLayoutAttributes = newValue
        }
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
         Global footer attributes: \(invalidateGlobalFooterMetrics)
         Attributes: \(invalidateFlowLayoutAttributes)
         Metrics: \(invalidateFlowLayoutDelegateMetrics)
         Items: \(invalidatedItemIndexPaths ?? [])
         Supplementary: \(invalidatedSupplementaryIndexPaths ?? [:])
        ---
        """
    }
    
}
