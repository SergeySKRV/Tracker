import UIKit

//MARK: - TrackerViewController Class

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
 
    
    // MARK: - UI Elements
    
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .plus), for: .normal)
        button.accessibilityIdentifier = "addTrackerButton"
        return button
    }()
    
    private lazy var trackersLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlackDay
        label.accessibilityIdentifier = "TrackersTitle"
        return label
    }()
    
    private lazy var stubImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .stub))
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
    }
    
    // MARK: - Actions
    
    @objc private func didTapAddTrackerButton() {
        
    }
    
    // MARK: - Configure UI
    
    private func setupUI() {
        view.backgroundColor = .ypWhiteDay
        view.addSubviews(addTrackerButton, trackersLabel, stubImageView)
        addTrackerButton.addTarget(self, action: #selector(didTapAddTrackerButton), for: .touchUpInside)
    }
    
    private func updateUI() {
        stubImageView.isHidden = !categories.isEmpty
    }
    
    private func setupConstraints() {
        
        addTrackerButton.pin
            .width(42)
            .height(42)
            .top(view.safeAreaLayoutGuide.topAnchor, offset: 1)
            .leading(view.safeAreaLayoutGuide.leadingAnchor, offset: 6)
        
        trackersLabel.pin
            .leading(view.safeAreaLayoutGuide.leadingAnchor, offset: 16)
            .top(addTrackerButton.bottomAnchor, offset: 1)
        
        stubImageView.pin
            .width(80)
            .height(80)
            .top(view.safeAreaLayoutGuide.topAnchor, offset: 402)
            .centerX(to: view.safeAreaLayoutGuide.centerXAnchor)
    }
    
    private func addTracker(_ newTracker: Tracker, to categoryIndex: Int) {
        guard categoryIndex < categories.count else { return }
        
        var updatedCategories = categories
        let targetCategory = updatedCategories[categoryIndex]
        var updatedTrackers = targetCategory.trackers
        updatedTrackers.append(newTracker)
        updatedCategories[categoryIndex] = TrackerCategory(
            title: targetCategory.title,
            trackers: updatedTrackers
        )
        categories = updatedCategories
    }
    
    private func markTrackerAsCompleted(id: UUID) {
        let record = TrackerRecord(trackerID: id, date: Date())
        completedTrackers.append(record)
    }
    
    private func unmarkTracker(id: UUID) {
        completedTrackers.removeAll { $0.trackerID == id}
    }
}
