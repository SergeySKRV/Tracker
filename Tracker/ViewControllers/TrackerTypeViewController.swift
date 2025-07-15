import UIKit
import SnapKit

// MARK: - TrackerTypeViewController
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

    // MARK: - Properties
    private let dataProvider: TrackerDataProviderProtocol

    // MARK: - Initialization
    init(dataProvider: TrackerDataProviderProtocol = TrackerDataProvider()) {
        self.dataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)
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

    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteDay
        title = "Создание трекера"
        navigationItem.hidesBackButton = true
        view.addSubviews(habitButton, eventButton)
    }

    private func setupConstraints() {
        habitButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(281)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        eventButton.snp.makeConstraints { make in
            make.top.equalTo(habitButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
    }

    // MARK: - Actions
    @objc private func didTapHabitButton() {
            let vc = AddTrackerViewController(
                type: .habit,
                dataProvider: dataProvider
            )
            navigationController?.pushViewController(vc, animated: true)
        }

        @objc private func didTapEventButton() {
            let vc = AddTrackerViewController(
                type: .event,
                dataProvider: dataProvider
            )
            navigationController?.pushViewController(vc, animated: true)
        }
}
