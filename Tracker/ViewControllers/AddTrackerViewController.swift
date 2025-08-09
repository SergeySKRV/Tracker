import UIKit
import SnapKit

// MARK: - AddTrackerViewControllerDelegate
protocol AddTrackerViewControllerDelegate: AnyObject {
    func addTrackerViewControllerDidCreateTracker(_ controller: AddTrackerViewController)
}

// MARK: - AddTrackerViewController
final class AddTrackerViewController: UIViewController, TrackerFormDelegate {
    
    // MARK: - Properties
    private let addViewModel: AddTrackerViewModel
    private let formVC: TrackerFormViewController
    private let trackerType: TrackerType
    weak var delegate: AddTrackerViewControllerDelegate?
    
    // MARK: - Lifecycle
    init(type: TrackerType, dataProvider: TrackerDataProviderProtocol = TrackerDataProvider.shared) {
        self.trackerType = type
        self.addViewModel = AddTrackerViewModel(type: type, dataProvider: dataProvider)
        self.formVC = TrackerFormViewController()
        super.init(nibName: nil, bundle: nil)
        setupForm()
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
        formVC.viewModel = addViewModel
        title = trackerType == .habit ?
            TrackerConstants.Text.newHabitTitle :
            TrackerConstants.Text.newEventTitle
        formVC.saveButton.setTitle(
            TrackerConstants.Text.createButton,
            for: .normal
        )
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    private func addChildViewController() {
        addChild(formVC)
        view.addSubview(formVC.view)
        formVC.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        formVC.didMove(toParent: self)
    }
    
    func didRequestSave(
        title: String,
        emoji: String,
        color: UIColor,
        schedule: Set<Weekday>,
        categoryId: UUID
    ) {
        addViewModel.saveTracker(
            title: title,
            emoji: emoji,
            color: color,
            schedule: schedule,
            categoryId: categoryId
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.delegate?.addTrackerViewControllerDidCreateTracker(self!)
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
