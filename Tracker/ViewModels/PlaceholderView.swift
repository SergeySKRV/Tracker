import UIKit
import SnapKit

// MARK: - PlaceholderView
final class PlaceholderView: UIView {
    private let imageView = UIImageView()
    private let label = UILabel()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Public Methods
    func configure(image: UIImage?, text: String) {
        imageView.image = image
        label.text = text
    }
    
    // MARK: - Private UI Setup
    private func setupUI() {
        imageView.contentMode = .scaleAspectFit
        
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .ypBlackDay
        
        addSubview(imageView)
        addSubview(label)
        
        imageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.size.equalTo(80)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
