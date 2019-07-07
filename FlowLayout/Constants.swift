import UIKit

public extension UICollectionView {
    static let elementKindBackground = "FlowLayoutBackgroundView"
    static let elementKindGlobalHeader = "FlowLayoutGlobalHeader"
    static let elementKindGlobalFooter = "FlowLayoutGlobalFooter"
    
    static let globalElementIndexPath = IndexPath(item: 0, section: 0)
    
    static let backgroundZIndex: Int = -1
    static let globalHeaderZIndex: Int = 400
    static let globalFooterZIndex: Int = 300
}
