import UIKit
import FlowLayout

extension UICollectionViewFlowLayout {
    
    func columnWidth(forColumnCount columnCount: Int, inSection section: Int) -> CGFloat {
        guard let collectionView = collectionView else { return 0 }
        
        let insets = self.insets(for: section)
        let interitemSpacing = self.interitemSpacing(for: section)
        
        let itemSpacing = CGFloat(columnCount - 1) * interitemSpacing
        var maximumWidth: CGFloat

        switch sectionInsetReference {
        case .fromContentInset:
            maximumWidth = collectionView.bounds.width
                - collectionView.adjustedContentInset.left
                - collectionView.adjustedContentInset.right
        case .fromSafeArea:
            maximumWidth = collectionView.bounds.width
                - collectionView.safeAreaInsets.left
                - collectionView.safeAreaInsets.right
        case .fromLayoutMargins:
            maximumWidth = collectionView.bounds.width
                - collectionView.layoutMargins.left
                - collectionView.layoutMargins.right
        default:
            maximumWidth = collectionView.bounds.width
        }

        let availableWidth = maximumWidth - insets.left - insets.right - itemSpacing
        return (availableWidth / CGFloat(columnCount)).rounded(.down)
    }
    
}


final class ViewController: UICollectionViewController, FlowLayoutDelegate {

    private var model: [[String]] = []
    
    private var flowLayout: FlowLayout {
        return collectionViewLayout as! FlowLayout
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // for testing
        navigationItem.largeTitleDisplayMode = .always
        
        for _ in 0..<3 {
            var models: [String] = []

            for _ in 0..<3 {
                models.append(Lorem.fullName)
            }

            model.append(models)
        }
        
        collectionView.alwaysBounceVertical = true
        collectionView.register(UINib(nibName: "Cell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.register(UINib(nibName: "GlobalView", bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindGlobalHeader,
                                withReuseIdentifier: UICollectionView.elementKindGlobalHeader)
        collectionView.register(UINib(nibName: "GlobalView", bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindGlobalFooter,
                                withReuseIdentifier: UICollectionView.elementKindGlobalFooter)
        collectionView.register(UICollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindBackground,
                                withReuseIdentifier: UICollectionView.elementKindBackground)
        
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        flowLayout.minimumLineSpacing = 20
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.sectionInsetReference = .fromSafeArea
    
        flowLayout.globalHeaderConfiguration.pinsToContent = true
//        flowLayout.globalHeaderConfiguration.pinsToBounds = true
//        flowLayout.globalHeaderConfiguration.prefersFollowContent = true
//        flowLayout.globalHeaderConfiguration.layoutFromSafeArea = false
        
//        flowLayout.globalFooterConfiguration.pinsToContent = true
        flowLayout.globalFooterConfiguration.pinsToBounds = true
        flowLayout.globalFooterConfiguration.prefersFollowContent = true
        flowLayout.globalFooterConfiguration.layoutFromSafeArea = false
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add(_:))),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(remove(_:)))
        ]
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        cachedItemSizes.removeAll()
        flowLayout.invalidateLayout()
    }
    
    @objc private func add(_ sender: Any?) {
        var models: [String] = []

        for _ in 0..<3 {
            models.append(Lorem.fullName)
        }

        model.append(models)
        collectionView.insertSections(IndexSet(integer: model.count - 1))
    }
    
    @objc private func remove(_ sender: Any?) {
        if model.isEmpty { return }
        model.removeFirst()
        collectionView.deleteSections(IndexSet(integer: 0))
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return model.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model[section].count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        cell.label.text = model[indexPath.section][indexPath.item]
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if model[indexPath.section].count == 1 {
            model.remove(at: indexPath.section)
            collectionView.deleteSections(IndexSet(integer: indexPath.section))
        } else {
            model[indexPath.section].remove(at: indexPath.item)
            collectionView.deleteItems(at: [indexPath])
        }
    }

    let cell = Cell.fromNib
    var cachedBounds: [IndexPath: CGRect] = [:]
    var cachedItemSizes: [IndexPath: CGSize] = [:]
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        defer {
            cachedBounds[indexPath] = collectionView.bounds
        }

        let width = flowLayout.columnWidth(forColumnCount: 3, inSection: indexPath.section)

        if let size = cachedItemSizes[indexPath] {
            return size
        }

        let target = CGSize(width: width, height: 0)

        cachedItemSizes[indexPath] = cell.contentView.systemLayoutSizeFitting(target, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return cachedItemSizes[indexPath] ?? .zero
    }

    let globalHeader = GlobalView.fromNib
    func heightForGlobalHeader(in collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout) -> CGFloat {
        globalHeader.setExpanded(isGlobalHeaderExpanded)
        let target = CGSize(width: collectionView.bounds.width, height: 0)
        return globalHeader.systemLayoutSizeFitting(target, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
    }

    let globalFooter = GlobalView.fromNib
    func heightForGlobalFooter(in collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout) -> CGFloat {
        globalFooter.setExpanded(isGlobalFooterExpanded)
        let target = CGSize(width: collectionView.bounds.width, height: 0)
        return globalFooter.systemLayoutSizeFitting(target, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
    }
    
    private var isGlobalHeaderExpanded: Bool = false
    private var isGlobalFooterExpanded: Bool = false
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindGlobalHeader:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: UICollectionView.elementKindGlobalHeader,
                                                                       for: indexPath) as! GlobalView
            
            view.setExpanded(isGlobalHeaderExpanded)
            
            view.onToggle = { [unowned self] in
                self.isGlobalHeaderExpanded.toggle()
                view.setExpanded(self.isGlobalHeaderExpanded)
                
                self.collectionView.performBatchUpdates({
                    let context = FlowLayoutInvalidationContext()
                    context.invalidateGlobalHeaderMetrics = true
                    self.flowLayout.invalidateLayout(with: context)
                }, completion: nil)
            }
            
            return view
        case UICollectionView.elementKindGlobalFooter:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: UICollectionView.elementKindGlobalFooter,
                                                                       for: indexPath) as! GlobalView
            
            view.setExpanded(isGlobalFooterExpanded)
            
            view.onToggle = { [unowned self] in
                self.isGlobalFooterExpanded.toggle()
                view.setExpanded(self.isGlobalFooterExpanded)
                
                self.collectionView.performBatchUpdates({
                    let context = FlowLayoutInvalidationContext()
                    context.invalidateGlobalFooterMetrics = true
                    self.flowLayout.invalidateLayout(with: context)
                }, completion: nil)
            }
            
            return view
        case UICollectionView.elementKindBackground:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: UICollectionView.elementKindBackground,
                                                                       for: indexPath)
            view.backgroundColor = UIColor(white: 0, alpha: 0.1)
            view.layer.cornerRadius = 12
            return view
        default:
            fatalError()
        }
    }
    
    func backgroundLayoutRegion(in collectionView: UICollectionView, forSectionAt section: Int) -> LayoutRegion {
        return .outerBounds
    }
    
    func backgroundLayoutInsets(in collectionView: UICollectionView, forSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

}
