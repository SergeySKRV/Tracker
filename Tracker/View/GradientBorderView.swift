import UIKit

// MARK: - GradientBorderView
final class GradientBorderView: UIView {
    
    // MARK: - Properties
    var gradientColors: [UIColor] = [] {
        didSet {
            updateGradient()
        }
    }
    
    private let gradientLayer = CAGradientLayer()
    private let maskLayer = CAShapeLayer()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    // MARK: - Override Methods
    override func layoutSubviews() {
        super.layoutSubviews()
       
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = 16
     
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 16)
        let innerRect = bounds.insetBy(dx: 1, dy: 1)
        let innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: 15)
        
        path.append(innerPath.reversing())
        maskLayer.path = path.cgPath
    }
    
    // MARK: - Private Methods
    private func setupGradient() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
       
        layer.mask = maskLayer
    }
    
    private func updateGradient() {
        gradientLayer.colors = gradientColors.map { $0.cgColor }
    }
}
