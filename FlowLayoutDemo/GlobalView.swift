import UIKit

final class GlobalView: UICollectionReusableView, NibLoadable {
    
    enum Mode {
        case collapsed
        case expanded
    }
    
    static let title = Lorem.title
    static let summary = Lorem.paragraphs(3)
    
    @IBOutlet private weak var toggleButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var summaryLabel: UILabel!
    
    @IBOutlet private var expandedConstraint: NSLayoutConstraint!
    @IBOutlet private var collapsedConstraint: NSLayoutConstraint!
    
    var onToggle: () -> Void = { }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        expandedConstraint.isActive = false
        collapsedConstraint.isActive = true
        toggleButton.isSelected = false
        
        titleLabel.text = type(of: self).title
        summaryLabel.text = type(of: self).summary
    }
    
    func setExpanded(_ expanded: Bool) {
        summaryLabel.isHidden = !expanded
        summaryLabel.layer.add(CATransition(), forKey: nil)
        expandedConstraint.isActive = expanded
        collapsedConstraint.isActive = !expanded
        toggleButton.isSelected = expanded
    }
    
    @IBAction func toggle(_ sender: Any?) {
        onToggle()
    }
    
}
