import UIKit
import SnapKit

// MARK: - TrackerCell
final class TrackerCell: UICollectionViewCell {
    
    // MARK: - Static Constants
    static let reuseIdentifier = "TrackerCell"
    
    // MARK: - Properties
    var onCheckButtonTapped: (() -> Void)?
    
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
        label.textColor = .ypBlackDayNight
        return label
    }()
    
    private lazy var checkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 17
        button.tintColor = .ypWhiteDayNight
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.imageView?.contentMode = .center
        button.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pin.fill")
        imageView.tintColor = .ypWhiteDayNight
        imageView.isHidden = true
        imageView.backgroundColor = .ypWhiteDayNight
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        return imageView
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
        
        pinImageView.backgroundColor = tracker.color
        pinImageView.isHidden = !tracker.isPinned
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        [cardView, daysCountLabel, checkButton, pinImageView].forEach { contentView.addSubview($0) }
        [emojiBackground, titleLabel].forEach { cardView.addSubview($0) }
        emojiBackground.addSubview(emojiLabel)
    }
    
    private func setupConstraints() {
        cardView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(90)
        }
        
        emojiBackground.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(24)
        }
        
        emojiLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        daysCountLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        checkButton.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(34)
        }
        
        pinImageView.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(18)
            make.trailing.equalTo(cardView).offset(-12)
            make.width.height.equalTo(12)
        }
    }
    
    func pluralizeDays(count: Int) -> String {
        return localizedDaysCount(count)
    }
    
    @objc private func checkButtonTapped() {
        onCheckButtonTapped?()
    }
}
