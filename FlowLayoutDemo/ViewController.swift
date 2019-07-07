import UIKit
import FlowLayout

extension FlowLayout {
    
    func columnWidth(forColumnCount columnCount: Int, inSection section: Int) -> CGFloat {
        guard let collectionView = collectionView else { return 0 }
        
        let insets = self.insets(for: section)
        let interitemSpacing = self.interitemSpacing(for: section)
        
        let itemSpacing = CGFloat(columnCount - 1) * interitemSpacing
        let availableWidth = collectionView.bounds.width - insets.left - insets.right - itemSpacing
        
        return (availableWidth / CGFloat(columnCount)).rounded(.down)
    }
    
}

final class ViewController: UICollectionViewController, FlowLayoutDelegate {
    
    private var model: [String] = []
    
    private var flowLayout: FlowLayout {
        return collectionViewLayout as! FlowLayout
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // for testing
        navigationItem.largeTitleDisplayMode = .never
//        navigationController?.isNavigationBarHidden = true
        
        for _ in 0..<50 {
            model.append(Lorem.fullName)
        }
        
        collectionView.alwaysBounceVertical = true
        collectionView.register(UINib(nibName: "Cell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.register(UINib(nibName: "GlobalView", bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindGlobalHeader,
                                withReuseIdentifier: UICollectionView.elementKindGlobalHeader)
        collectionView.register(UINib(nibName: "GlobalView", bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindGlobalFooter,
                                withReuseIdentifier: UICollectionView.elementKindGlobalFooter)
        
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        flowLayout.minimumLineSpacing = 20
        flowLayout.minimumInteritemSpacing = 20
    
        flowLayout.globalHeaderConfiguration.pinsToContent = true
        flowLayout.globalHeaderConfiguration.pinsToBounds = true
        flowLayout.globalHeaderConfiguration.prefersFollowContent = true
        flowLayout.globalHeaderConfiguration.layoutFromSafeArea = false
        
        flowLayout.globalFooterConfiguration.pinsToContent = true
        flowLayout.globalFooterConfiguration.pinsToBounds = true
//        flowLayout.globalFooterConfiguration.prefersFollowContent = true
        flowLayout.globalFooterConfiguration.layoutFromSafeArea = false
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add(_:))),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(remove(_:)))
        ]
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "Header", style: .plain, target: self, action: #selector(toggleGlobalHeader(_:))),
            UIBarButtonItem(title: "Footer", style: .plain, target: self, action: #selector(toggleGlobalFooter(_:)))
        ]
    }
    
    private var globalHeaderHeight: CGFloat = 44
    private var isGlobalHeaderHidden: Bool = false
    @objc private func toggleGlobalHeader(_ sender: Any?) {
        print("\n--- \(isGlobalHeaderHidden ? "Header Shown" : "Header Hidden")\n")
//        isGlobalHeaderHidden.toggle()
        globalHeaderHeight = globalHeaderHeight > 44 ? 44 : 100
        
        collectionView.performBatchUpdates({
            let context = FlowLayoutInvalidationContext()
            context.invalidateGlobalHeader = true
            flowLayout.invalidateLayout(with: context)
        }, completion: nil)
    }
    
    private var isGlobalFooterHidden: Bool = false
    @objc private func toggleGlobalFooter(_ sender: Any?) {
        print("\n--- \(isGlobalFooterHidden ? "Footer Shown" : "Footer Hidden")\n")
        isGlobalFooterHidden.toggle()
        
        let context = FlowLayoutInvalidationContext()
        context.invalidateGlobalFooter = true
        flowLayout.invalidateLayout(with: context)
    }
    
    @objc private func add(_ sender: Any?) {
        print("\n--- Add\n")
        model.append(Lorem.fullName)
        collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
    }
    
    @objc private func remove(_ sender: Any?) {
        guard model.count > 0 else { return }
        print("\n--- Remove\n")
        model.remove(at: 0)
        collectionView.deleteItems(at: [IndexPath(item: 0, section: 0)])
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        cell.label.text = model[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = flowLayout.columnWidth(forColumnCount: 3, inSection: indexPath.section)
        let cell = Cell.fromNib
        let target = CGSize(width: width, height: 0)
        return cell.contentView.systemLayoutSizeFitting(target, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
    
    func heightForGlobalHeader(in collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout) -> CGFloat {
        return isGlobalHeaderHidden ? 0 : globalHeaderHeight
    }
    
    func heightForGlobalFooter(in collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout) -> CGFloat {
        return isGlobalFooterHidden ? 0 : 44
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindGlobalHeader:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: UICollectionView.elementKindGlobalHeader,
                                                                   for: indexPath)
        case UICollectionView.elementKindGlobalFooter:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: UICollectionView.elementKindGlobalFooter,
                                                                   for: indexPath)
        default:
            fatalError()
        }
    }

}
