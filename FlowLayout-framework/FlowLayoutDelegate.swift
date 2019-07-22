import UIKit

@objc public protocol FlowLayoutDelegate: UICollectionViewDelegateFlowLayout {
    
    /// Returns the height for the global header. Return 0 to hide the global header
    @objc optional func heightForGlobalHeader(in collectionView: UICollectionView,
                                              layout collectionViewLayout: UICollectionViewLayout) -> CGFloat
    
    /// Returns the height for the global header. Return 0 to hide the global header
    @objc optional func heightForGlobalFooter(in collectionView: UICollectionView,
                                              layout collectionViewLayout: UICollectionViewLayout) -> CGFloat
    
    /// Returns the background style to apply for the specified section. Returning a value other that `.none` will
    /// ensure UICollectionView will request a supplementary view from your collection's dataSource.
    @objc optional func backgroundLayoutStyle(in collectionView: UICollectionView,
                                              forSectionAt section: Int) -> BackgroundLayoutStyle
    
    /// Returns insets that will be used to layout the background view.
    @objc optional func backgroundLayoutInsets(in collectionView: UICollectionView,
                                               forSectionAt section: Int) -> UIEdgeInsets
    
}
