import UIKit

// MARK: - TrackerTypeViewController Class
final class TrackerTypeViewController: UIViewController {
    
    // MARK: - UI Elements
    private lazy var habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlackDay
        button.tintColor = .ypWhiteDay
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapHabitButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var eventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlackDay
        button.tintColor = .ypWhiteDay
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapEventButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteDay
        title = "Создание трекера"
        navigationItem.hidesBackButton = true
        view.addSubviews(habitButton, eventButton)
    }
    
    private func setupConstraints() {
        habitButton.pin
            .top(view.safeAreaLayoutGuide.topAnchor, offset: 281)
            .leading(view.leadingAnchor, offset: 20)
            .trailing(view.trailingAnchor, offset: -20)
            .height(60)
        
        eventButton.pin
            .top(habitButton.bottomAnchor, offset: 16)
            .leading(view.leadingAnchor, offset: 20)
            .trailing(view.trailingAnchor, offset: -20)
            .height(60)
    }
    
    // MARK: - Actions
    @objc private func didTapHabitButton() {
        let vc = AddTrackerViewController(type: .habit)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapEventButton() {
        let vc = AddTrackerViewController(type: .event)
        navigationController?.pushViewController(vc, animated: true)
    }
}
