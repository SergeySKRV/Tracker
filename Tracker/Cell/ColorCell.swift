import UIKit
import SnapKit

// MARK: - ColorCell
final class ColorCell: UICollectionViewCell {
    
    // MARK: - Static Constants
    static let reuseIdentifier = "ColorCell"
    
    // MARK: - Properties
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Public Methods
    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        
        if isSelected {
            contentView.layer.borderWidth = 3
            contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = nil
        }
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        colorView.backgroundColor = nil
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = nil
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        contentView.addSubview(colorView)
        contentView.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        colorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }
}
