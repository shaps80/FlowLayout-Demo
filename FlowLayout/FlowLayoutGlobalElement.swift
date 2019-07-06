import UIKit

open class FlowLayoutGlobalElement: NSObject {
    
    open var preferences: GlobalPreferences = .init()
    
    open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return preferences.pinsToBounds || preferences.pinsToContent
    }
    
}
