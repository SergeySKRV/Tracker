import UIKit

// MARK: - UIView + Subviews
extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
