import UIKit

// MARK: - UIView + Subviews
extension UIView {
    
    // MARK: - Methods
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
