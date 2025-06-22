import UIKit

// MARK: - Pin Layout Class

final class Pin {
    private let view: UIView
    init(view: UIView) {
        self.view = view
    }
    
    // MARK: - Position Constraints
    
    @discardableResult
    func top(_ anchor: NSLayoutYAxisAnchor, offset: CGFloat = 0) -> Self {
        view.topAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
        return self
    }
    
    @discardableResult
    func leading(_ anchor: NSLayoutXAxisAnchor, offset: CGFloat = 0) -> Self {
        view.leadingAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
        return self
    }
    
    @discardableResult
    func trailing(_ anchor: NSLayoutXAxisAnchor, offset: CGFloat = 0) -> Self {
        view.trailingAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
        return self
    }
    
    @discardableResult
    func bottom(_ anchor: NSLayoutYAxisAnchor, offset: CGFloat = 0) -> Self {
        view.bottomAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
        return self
    }
    
    @discardableResult
    func centerX(to anchor: NSLayoutXAxisAnchor, offset: CGFloat = 0) -> Self {
        view.centerXAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
        return self
    }
    
    @discardableResult
    func centerY(to anchor: NSLayoutYAxisAnchor, offset: CGFloat = 0) -> Self {
        view.centerYAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
        return self
    }
    
    @discardableResult
    func width(_ dimension: NSLayoutDimension, multiplier: CGFloat = 1.0, offset: CGFloat = 0) -> Self {
        view.widthAnchor.constraint(equalTo: dimension, multiplier: multiplier, constant: offset).isActive = true
        return self
    }
    
    @discardableResult
    func width(_ value: CGFloat) -> Self {
        view.widthAnchor.constraint(equalToConstant: value).isActive = true
        return self
    }
    
    @discardableResult
    func height(_ dimension: NSLayoutDimension, multiplier: CGFloat = 1.0, offset: CGFloat = 0) -> Self {
        view.heightAnchor.constraint(equalTo: dimension, multiplier: multiplier, constant: offset).isActive = true
        return self
    }
    
    @discardableResult
    func height(_ value: CGFloat) -> Self {
        view.heightAnchor.constraint(equalToConstant: value).isActive = true
        return self
    }
    
    @discardableResult
    func size(_ size: CGSize) -> Self {
        width(size.width)
        height(size.height)
        return self
    }
}

// MARK: - UIView Extension for Pin

extension UIView {
    var pin: Pin {
        return Pin(view: self)
    }
}
