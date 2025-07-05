import UIKit

// MARK: - ScheduleViewController Class
final class ScheduleViewController: UIViewController {
    
    // MARK: - Properties
    private let daysOfWeek = Weekday.allCases
    private var selectedDays: Set<Weekday>
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    weak var delegate: ScheduleSelectionDelegate?
    
    // MARK: - UI Elements
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhiteDay, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlackDay
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    init(selectedDays: Set<Weekday> = []) {
        self.selectedDays = selectedDays
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
        setupNavigation()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteDay
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        tableView.backgroundColor = .ypWhiteDay
        tableView.separatorColor = .ypGray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.addSubviews(tableView, doneButton)
    }
    
    private func setupConstraints() {
        tableView.pin
            .top(view.safeAreaLayoutGuide.topAnchor)
            .leading(view.leadingAnchor)
            .trailing(view.trailingAnchor)
            .bottom(doneButton.topAnchor, offset: -16)
        
        doneButton.pin
            .bottom(view.safeAreaLayoutGuide.bottomAnchor, offset: -16)
            .leading(view.leadingAnchor, offset: 20)
            .trailing(view.trailingAnchor, offset: -20)
            .height(60)
    }
    
    private func setupNavigation() {
        title = "Расписание"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
    }
    
    // MARK: - Actions
    @objc private func switchValueChanged(_ sender: UISwitch) {
        let day = daysOfWeek[sender.tag]
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
    
    @objc private func doneButtonTapped() {
        delegate?.didSelectSchedule(selectedDays)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let day = daysOfWeek[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = day.fullName
        content.textProperties.font = UIFont.systemFont(ofSize: 17)
        cell.contentConfiguration = content
        cell.backgroundColor = .ypBackgroundDay
        
        let switchView = UISwitch()
        switchView.onTintColor = .ypBlue
        switchView.isOn = selectedDays.contains(day)
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
            switchValueChanged(switchView)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == daysOfWeek.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

// MARK: - Delegate Protocol
protocol ScheduleSelectionDelegate: AnyObject {
    func didSelectSchedule(_ selectedDays: Set<Weekday>)
}
