import UIKit

// MARK: - TrackerCategoryHeaderView
final class TrackerCategoryHeaderView: UICollectionReusableView {
    static let identifier = "TrackerCategoryHeaderView"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.textColor = .ypBlackDay
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    private func setupViews() {
        addSubviews(titleLabel)
        
        titleLabel.pin
            .leading(leadingAnchor, offset: 28)
            .top(topAnchor)
            .bottom(bottomAnchor)
            .trailing(trailingAnchor, offset: -16, relation: .lessThanOrEqual)
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
