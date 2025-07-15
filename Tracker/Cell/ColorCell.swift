import UIKit
import SnapKit

final class ColorCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCell"
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    private func setupViews() {
        contentView.backgroundColor = .clear
        contentView.addSubview(colorView)
    }
    
    private func setupConstraints() {
        colorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(46)
        }
    }
    
    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        
        if isSelected {
            contentView.layer.borderWidth = 3
            contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
            contentView.layer.cornerRadius = 8
            contentView.layer.masksToBounds = true
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.cornerRadius = 0
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.layer.borderWidth = 0
        contentView.layer.cornerRadius = 0
        contentView.layer.masksToBounds = false
    }
}
