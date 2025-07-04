import UIKit

// MARK: - TrackerCell Class
final class TrackerCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    
    // MARK: - Properties
    var onCheckButtonTapped: (() -> Void)?
    
    // MARK: - UI Elements
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let emojiBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        return label
    }()
    
    private lazy var checkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 17
        button.tintColor = .white
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.imageView?.contentMode = .center
        button.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Public Methods
    func configure(with tracker: Tracker, isCompleted: Bool, completionCount: Int, selectedDate: Date) {
        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        daysCountLabel.text = pluralizeDays(count: completionCount)

        let image = isCompleted ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        checkButton.setImage(image, for: .normal)
        checkButton.backgroundColor = tracker.color.withAlphaComponent(isCompleted ? 0.3 : 1.0)
        
        let canMark = selectedDate <= Date()
        checkButton.isEnabled = canMark
        checkButton.alpha = canMark ? 1.0 : 0.3
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        contentView.addSubviews(cardView, daysCountLabel, checkButton)
        cardView.addSubviews(emojiBackground, titleLabel)
        emojiBackground.addSubviews(emojiLabel)
    }
    
    private func setupConstraints() {
        cardView.pin
            .top(contentView.topAnchor)
            .leading(contentView.leadingAnchor)
            .trailing(contentView.trailingAnchor)
            .height(90)
        
        emojiBackground.pin
            .top(cardView.topAnchor, offset: 12)
            .leading(cardView.leadingAnchor, offset: 12)
            .width(24)
            .height(24)
        
        emojiLabel.pin
            .centerX(to: emojiBackground.centerXAnchor)
            .centerY(to: emojiBackground.centerYAnchor)
      
        titleLabel.pin
            .leading(cardView.leadingAnchor, offset: 12)
            .trailing(cardView.trailingAnchor, offset: -12)
            .bottom(cardView.bottomAnchor, offset: -12)
   
        daysCountLabel.pin
            .top(cardView.bottomAnchor, offset: 16)
            .leading(contentView.leadingAnchor, offset: 12)
            .bottom(contentView.bottomAnchor, offset: -24)
      
        checkButton.pin
            .top(cardView.bottomAnchor, offset: 8)
            .trailing(contentView.trailingAnchor, offset: -16)
            .width(34)
            .height(34)
    }
    
    private func pluralizeDays(count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        
        if remainder10 == 1 && remainder100 != 11 {
            return "\(count) день"
        } else if remainder10 >= 2 && remainder10 <= 4 && (remainder100 < 10 || remainder100 >= 20) {
            return "\(count) дня"
        } else {
            return "\(count) дней"
        }
    }
    
    // MARK: - Actions
    @objc private func checkButtonTapped() {
        onCheckButtonTapped?()
    }
}
