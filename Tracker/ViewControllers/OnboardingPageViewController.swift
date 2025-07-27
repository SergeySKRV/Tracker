import UIKit
import SnapKit

// MARK: - Onboarding Page View Controller
final class OnboardingPageViewController: UIViewController {
    
    // MARK: - Properties
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    // MARK: - Initialization
    init(imageName: String, title: String) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = UIImage(named: imageName)
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteDay
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = .ypBlackDay
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-270)
        }
    }
}
