import UIKit

@objc public enum BackgroundLayoutStyle: Int {
    /// No background will be shown
    case none
    /// A background will be added within the section's bounds including the header and footer areas
    case outerBounds
    /// A background will be added within the section's bounds excluding the header and footer areas
    case innerBounds
}

/// Represents a set of preferences for configuring a global element's behaviour in a `Composed.FlowLayout`
public struct GlobalElementConfiguration {
    
    /// If true, the global element will remain pinned to the collectionView's bounds
    public var pinsToBounds: Bool = true
    /// If true, the global element will remain pinned to the collectionView's content
    public var pinsToContent: Bool = false
    /// If true, the global element will remain pinned to the collectionView's bounds, unless the content forces the element off-screen.
    public var prefersFollowContent: Bool = false
    /// The inset to use betweent his element and the associated section. Useful for creating additional spacing, similar to sectionInsets
    public var inset: CGFloat = 0
    /// If true, the global element will respect any safeAreaInsets. If false, the element will be positioned relative to the bounds
    public var layoutFromSafeArea: Bool = true
    
    internal init() { }
    
}
