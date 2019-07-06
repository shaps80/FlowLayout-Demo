import UIKit

public extension UICollectionView {
    static let elementKindBackground = "DataSourceBackgroundView"
    static let elementKindGlobalHeader = "DataSourceGlobalHeader"
    static let elementKindGlobalFooter = "DataSourceGlobalFooter"
    static let globalElementIndexPath = IndexPath(item: 0, section: 0)
    
    static let backgroundZIndex: Int = -100
    static let globalHeaderZIndex: Int = 400
    static let globalFooterZIndex: Int = 300
    static let sectionHeaderZIndex: Int = 200
    static let sectionFooterZIndex: Int = 100
}
