import UIKit

public extension UICollectionView {
    /// Used for all supplementaryView's representing a section background
    static let elementKindBackground = "FlowLayoutBackgroundView"
    /// Used for the supplementaryView representing a global header
    static let elementKindGlobalHeader = "FlowLayoutGlobalHeader"
    /// Used for the supplementaryView representing a global footer
    static let elementKindGlobalFooter = "FlowLayoutGlobalFooter"
    /// The indexPath representing a global element
    static let globalElementIndexPath = IndexPath(item: 0, section: 0)
    /// The zIndex for all supplementaryView's representing a section background
    static let backgroundZIndex: Int = -1
    /// The zIndex for the supplementaryView representing a global header
    static let globalHeaderZIndex: Int = 400
    /// The zIndex for the supplementaryView representing a global footer
    static let globalFooterZIndex: Int = 300
}
