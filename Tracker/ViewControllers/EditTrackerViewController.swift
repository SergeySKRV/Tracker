import UIKit
import SnapKit
import AppMetricaCore

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
   
        let openEvent = [
            "event": "open",
            "screen": "EditTracker",
            "tracker_name": editViewModel.trackerTitle
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: openEvent)
        print("Analytics: \(openEvent)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
 
        let closeEvent = [
            "event": "close",
            "screen": "EditTracker",
            "tracker_name": editViewModel.trackerTitle
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: closeEvent)
        print("Analytics: \(closeEvent)")
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
        label.textColor = .ypBlackDayNight
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
       
        let saveEvent = [
            "event": "click",
            "screen": "EditTracker",
            "item": "save_tracker",
            "tracker_name": title,
            "emoji": emoji
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: saveEvent)
        print("Analytics: \(saveEvent)")
        
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
           
                    let successEvent = [
                        "event": "click",
                        "screen": "EditTracker",
                        "item": "save_success",
                        "tracker_name": title
                    ]
                    AppMetrica.reportEvent(name: "Screen Event", parameters: successEvent)
                    print("Analytics: \(successEvent)")
                    
                    self?.dismiss(animated: true)
                case .failure(let error):
      
                    AppMetrica.reportEvent(name: "Tracker Update Failed", parameters: [
                        "error": error.localizedDescription,
                        "tracker_name": title
                    ])
                    
                    self?.formVC.showAlert(title: NSLocalizedString("Ошибка", comment: ""), message: error.localizedDescription)
                }
            }
        }
    }
    
    func didRequestCancel() {

        let cancelEvent = [
            "event": "click",
            "screen": "EditTracker",
            "item": "cancel_edit"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: cancelEvent)
        print("Analytics: \(cancelEvent)")
        
        dismiss(animated: true)
    }
}
