import UIKit
import SnapKit

final class EmojiCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiCell"
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        label.backgroundColor = .clear
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    private func setupView() {
        contentView.backgroundColor = .clear
        contentView.addSubview(emojiLabel)
    }
    
    private func setupConstraints() {
        emojiLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func configure(with emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        contentView.backgroundColor = isSelected ? .ypLightGray : .clear
        contentView.layer.cornerRadius = isSelected ? 16 : 0
        contentView.layer.masksToBounds = isSelected
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 0
        contentView.layer.masksToBounds = false
    }
}
