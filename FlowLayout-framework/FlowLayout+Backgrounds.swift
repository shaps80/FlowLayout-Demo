import UIKit

internal extension FlowLayout {

    // Returns attributes for a section background
    func backgroundAttributes(section: Int, numberOfItems: Int, style: BackgroundLayoutStyle, insets: UIEdgeInsets) -> FlowLayoutAttributes? {
        guard let collectionView = collectionView else { return nil }

        let firstIndex = 0
        let lastIndex = numberOfItems - 1
        guard lastIndex >= 0 else { return nil }

        guard let firstAttributes = super.layoutAttributesForItem(at: IndexPath(item: firstIndex, section: section)),
            let lastAttributes = super.layoutAttributesForItem(at: IndexPath(item: lastIndex, section: section)) else {
                return nil
        }

        let indexPath = IndexPath(item: 0, section: section)
        let sectionInsets = self.insets(for: section)
        let bgAttributes = FlowLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindBackground, with: indexPath)

        let x: CGFloat = 0
        let w: CGFloat = collectionView.bounds.width
        var y: CGFloat = firstAttributes.frame.minY
        var h: CGFloat = lastAttributes.frame.maxY - firstAttributes.frame.minY

        switch style {
        case .outerBounds:
            let headerHeight = super.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath)?.size.height ?? 0
            let footerHeight = super.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: indexPath)?.size.height ?? 0
            y -= headerHeight + sectionInsets.top
            h += headerHeight + footerHeight + sectionInsets.top + sectionInsets.bottom
        case .innerBounds:
            y -= sectionInsets.top
            h += sectionInsets.top + sectionInsets.bottom
        case .none:
            return nil
        }

        bgAttributes.frame = CGRect(x: x, y: y, width: w, height: h).inset(by: insets)
        bgAttributes.zIndex = UICollectionView.backgroundZIndex

        return bgAttributes
    }

}
