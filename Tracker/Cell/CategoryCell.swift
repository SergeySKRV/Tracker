import UIKit
import SnapKit

final class CategoryCell: UITableViewCell {
    static let identifier = "CategoryCell"
    
    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackgroundDay
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlackDay
        label.numberOfLines = 1
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.tintColor = .ypBlue
        imageView.isHidden = true
        return imageView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        [titleLabel, checkmarkImageView, separatorView].forEach {
            containerView.addSubview($0)
        }
        
        checkmarkImageView.image = UIImage(systemName: "checkmark")
        
        // Включаем маскирование
        containerView.layer.masksToBounds = true
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(contentView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(containerView).offset(16)
            make.centerY.equalTo(containerView)
            make.trailing.lessThanOrEqualTo(checkmarkImageView.snp.leading).offset(-16)
        }
        
        checkmarkImageView.snp.makeConstraints { make in
            make.trailing.equalTo(containerView).offset(-24)
            make.centerY.equalTo(containerView)
            make.width.height.equalTo(30)
        }
        
        separatorView.snp.makeConstraints { make in
            make.leading.equalTo(containerView).offset(16)
            make.trailing.equalTo(containerView).offset(-16)
            make.bottom.equalTo(containerView)
            make.height.equalTo(0.5)
        }
    }
    
    func configure(title: String, isSelected: Bool, isFirstCell: Bool = false, isLastCell: Bool = false) {
        titleLabel.text = title
        checkmarkImageView.isHidden = !isSelected
        
        separatorView.isHidden = isLastCell
        
        var maskedCorners: CACornerMask = []
        var cornerRadius: CGFloat = 0
        
        if isFirstCell && isLastCell {
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                             .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cornerRadius = 16
        } else if isFirstCell {
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cornerRadius = 16
        } else if isLastCell {
            maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cornerRadius = 16
        }
        
        containerView.layer.maskedCorners = maskedCorners
        containerView.layer.cornerRadius = cornerRadius
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        checkmarkImageView.isHidden = true
        separatorView.isHidden = false
        containerView.layer.maskedCorners = []
        containerView.layer.cornerRadius = 0
    }
}
