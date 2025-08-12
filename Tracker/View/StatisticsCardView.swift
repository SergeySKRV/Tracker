import UIKit
import SnapKit

// MARK: - StatisticCardView
final class StatisticCardView: UIView {
    
    // MARK: - Static Constants
    
    // MARK: - UI Properties
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let gradientView = GradientBorderView()
    
    // MARK: - Lifecycle
    init(title: String, value: String, gradientColors: [UIColor]) {
        super.init(frame: .zero)
        configure(with: title, value: value, gradientColors: gradientColors)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Public Methods
    var value: String {
        set {
            valueLabel.text = newValue
        }
        get {
            return valueLabel.text ?? ""
        }
    }
    
    // MARK: - Private Methods
    private func configure(with title: String, value: String, gradientColors: [UIColor]) {
        backgroundColor = .clear
       
        gradientView.gradientColors = gradientColors
        addSubview(gradientView)
       
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        valueLabel.textColor = .ypBlackDayNight
        valueLabel.textAlignment = .left
        addSubview(valueLabel)
    
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .ypBlackDayNight
        titleLabel.textAlignment = .left
        addSubview(titleLabel)
        
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        layer.cornerRadius = 16
        clipsToBounds = true
    }
}
