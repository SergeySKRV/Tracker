import UIKit

// MARK: - EditTrackerViewController
final class EditTrackerViewController: TrackerFormViewController {
    // MARK: - Private Properties
    private let editViewModel: EditTrackerViewModel
    
    // MARK: - Lifecycle
    init(
        tracker: Tracker,
        categoryTitle: String,
        dataProvider: TrackerDataProviderProtocol = TrackerDataProvider.shared
    ) {
        self.editViewModel = EditTrackerViewModel(
            tracker: tracker,
            categoryTitle: categoryTitle,
            dataProvider: dataProvider
        )
        super.init(nibName: nil, bundle: nil)
        self.viewModel = editViewModel
        
        self.daysCountLabel = {
            let label = UILabel()
            label.text = editViewModel.pluralizeDays(count: editViewModel.daysCompleted)
            label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
            label.textColor = .ypBlackDay
            label.textAlignment = .center
            return label
        }()
        
        title = "Редактирование привычки"
        saveButton.setTitle(TrackerConstants.Text.saveButton, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.text = editViewModel.trackerTitle
        selectedCategoryTitle = editViewModel.selectedCategoryTitle
    }
    
    // MARK: - Actions
    @objc override func didTapSave() {
        editViewModel.saveTracker { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.dismiss(animated: true)
                case .failure(let error):
                    self?.showAlert(title: "Ошибка", message: error.localizedDescription)
                }
            }
        }
    }
}
