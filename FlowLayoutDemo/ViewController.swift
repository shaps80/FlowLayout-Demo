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

final class Cell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    static var fromNib: Cell {
        return UINib(nibName: "Cell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! Cell
    }
    
}

final class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private var model: [String] = []
    
    private var flowLayout: FlowLayout {
        return collectionViewLayout as! FlowLayout
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0..<5 {
            model.append(Lorem.fullName)
        }
        
        collectionView.alwaysBounceVertical = true
        collectionView.register(UINib(nibName: "Cell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        flowLayout.minimumLineSpacing = 20
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add(_:))),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(remove(_:)))
        ]
    }
    
    @objc private func add(_ sender: Any?) {
        print("--- Add")
        model.append(Lorem.fullName)
        collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
    }
    
    @objc private func remove(_ sender: Any?) {
        guard model.count > 0 else { return }
        print("--- Remove")
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
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = flowLayout.columnWidth(forColumnCount: 1, inSection: indexPath.section)
        let cell = Cell.fromNib
        let target = CGSize(width: width, height: 0)
        return cell.contentView.systemLayoutSizeFitting(target, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }

}
