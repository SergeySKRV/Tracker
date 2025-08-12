import UIKit
import SnapKit

// MARK: - ScheduleSelectionDelegate
protocol ScheduleSelectionDelegate: AnyObject {
    func didSelectSchedule(_ selectedDays: Set<Weekday>)
}

// MARK: - ScheduleViewController
final class ScheduleViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ScheduleViewModel
    weak var delegate: ScheduleSelectionDelegate?
    
    // MARK: - UI Elements
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Готово", comment: ""), for: .normal)
        button.setTitleColor(.ypWhiteDayNight, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlackDayNight
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    init(viewModel: ScheduleViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupNavigation()
        bindViewModel()
      
        AnalyticsService.shared.reportEvent(AnalyticsEvent(type: .open, screen: .schedule))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
        AnalyticsService.shared.reportEvent(AnalyticsEvent(type: .close, screen: .schedule))
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteDayNight
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        tableView.backgroundColor = .ypWhiteDayNight
        tableView.separatorColor = .ypGray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.addSubviews(tableView, doneButton)
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(doneButton.snp.top).offset(-16)
        }
        
        doneButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
    }
    
    private func setupNavigation() {
        title = NSLocalizedString("Расписание", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.hidesBackButton = true
    }
    
    private func bindViewModel() {
        viewModel.onSelectionChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    @objc private func doneButtonTapped() {
        AnalyticsService.shared.reportEvent(AnalyticsEvent(type: .click, screen: .schedule, item: .done))
        
        delegate?.didSelectSchedule(viewModel.selectedDays)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfDays()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard let day = viewModel.day(at: indexPath.row) else { return UITableViewCell() }
        
        var content = cell.defaultContentConfiguration()
        content.text = day.fullName
        content.textProperties.font = UIFont.systemFont(ofSize: 17)
        cell.contentConfiguration = content
        cell.backgroundColor = .ypBackground
        
        let switchView = UISwitch()
        switchView.onTintColor = .ypBlue
        switchView.isOn = viewModel.isDaySelected(at: indexPath.row)
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        cell.accessoryView = switchView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath),
           let switchView = cell.accessoryView as? UISwitch {
            switchView.setOn(!switchView.isOn, animated: true)
            viewModel.toggleDay(at: indexPath.row)
            
            let day = viewModel.day(at: indexPath.row)
            AnalyticsService.shared.reportEvent(AnalyticsEvent(
                type: .click,
                screen: .schedule,
                item: .daySelected,
                additionalParameters: [
                    "day": day?.fullName ?? "Unknown"
                ]
            ))
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.numberOfDays() - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        viewModel.toggleDay(at: sender.tag)
      
        let day = viewModel.day(at: sender.tag)
        AnalyticsService.shared.reportEvent(AnalyticsEvent(
            type: .click,
            screen: .schedule,
            item: .switchChanged,
            additionalParameters: [
                "day": day?.fullName ?? "Unknown",
                "is_on": sender.isOn
            ]
        ))
    }
}
