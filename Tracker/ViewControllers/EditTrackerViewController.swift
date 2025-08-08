import UIKit
import SnapKit

// MARK: - EditTrackerViewController
final class EditTrackerViewController: UIViewController, TrackerFormDelegate {
    
    // MARK: - Properties
    private let editViewModel: EditTrackerViewModel
    private let formVC: TrackerFormViewController
    
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
        self.formVC = TrackerFormViewController()
        super.init(nibName: nil, bundle: nil)
        
        setupForm()
        setupInitialValues()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViewController()
    }
    
    // MARK: - Private Methods
    private func setupForm() {
        formVC.delegate = self
        formVC.viewModel = editViewModel
        
        formVC.daysCountLabel = createDaysCountLabel()
        title = NSLocalizedString("Редактирование привычки", comment: "")
        formVC.saveButton.setTitle(TrackerConstants.Text.saveButton, for: .normal)
    }
    
    private func setupInitialValues() {
        formVC.titleTextField.text = editViewModel.trackerTitle
        formVC.selectedCategoryTitle = editViewModel.selectedCategoryTitle
    }
    
    private func addChildViewController() {
        addChild(formVC)
        view.addSubview(formVC.view)
        formVC.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        formVC.didMove(toParent: self)
    }
    
    private func createDaysCountLabel() -> UILabel {
        let label = UILabel()
        label.text = editViewModel.pluralizeDays(count: editViewModel.daysCompleted)
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlackDay
        label.textAlignment = .center
        return label
    }
    
    // MARK: - TrackerFormDelegate
    func didRequestSave(
        title: String,
        emoji: String,
        color: UIColor,
        schedule: Set<Weekday>,
        categoryId: UUID
    ) {
        editViewModel.saveTracker(
            title: title,
            emoji: emoji,
            color: color,
            schedule: schedule,
            categoryId: categoryId
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.dismiss(animated: true)
                case .failure(let error):
                    self?.formVC.showAlert(title: NSLocalizedString("Ошибка", comment: ""), message: error.localizedDescription)
                }
            }
        }
    }
    
    func didRequestCancel() {
        dismiss(animated: true)
    }
}
