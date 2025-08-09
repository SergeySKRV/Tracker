import UIKit
import SnapKit

// MARK: - EmojiCell
final class EmojiCell: UICollectionViewCell {
    
    // MARK: - Static Constants
    static let reuseIdentifier = "EmojiCell"
    
    // MARK: - UI Properties
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Override Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        emojiLabel.text = nil
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 0
    }
    
    // MARK: - Public Methods
    func configure(with emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        
        if isSelected {
            contentView.backgroundColor = .ypLightGray
            contentView.layer.cornerRadius = 16
            contentView.layer.masksToBounds = true
        } else {
            contentView.backgroundColor = .clear
            contentView.layer.cornerRadius = 0
        }
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        contentView.addSubview(emojiLabel)
        contentView.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        emojiLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }
}
