import UIKit

// MARK: - AddTrackerViewController
final class AddTrackerViewController: TrackerFormViewController {
    // MARK: - Private Properties
    private let addViewModel: AddTrackerViewModel
    
    // MARK: - Lifecycle
    init(type: TrackerType, dataProvider: TrackerDataProviderProtocol = TrackerDataProvider.shared) {
        self.addViewModel = AddTrackerViewModel(type: type, dataProvider: dataProvider)
        super.init(nibName: nil, bundle: nil)
        self.viewModel = addViewModel
        title = type == .habit ? TrackerConstants.Text.newHabitTitle : TrackerConstants.Text.newEventTitle
        saveButton.setTitle(TrackerConstants.Text.createButton, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    @objc override func didTapSave() {
        addViewModel.saveTracker { [weak self] result in
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
