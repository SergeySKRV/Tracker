import UIKit
import SnapKit

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
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(28)
            make.top.bottom.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
