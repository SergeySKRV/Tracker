import UIKit

// MARK: - UIView Extension: Subviews Management
extension UIView {
    
    // MARK: - Public Methods
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
