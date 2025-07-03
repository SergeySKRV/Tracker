import UIKit

enum TrackerType {
    case habit
    case event
}

// MARK: - AddTrackerViewController Class
final class AddTrackerViewController: UIViewController {
    
    // MARK: - Properties
    private let type: TrackerType
    private var selectedDays: Set<Weekday> = []
    private var trackerTitle: String = ""
    private var options: [String] {
        type == .habit ? ["Категория", "Расписание"] : ["Категория"]
    }
    
    // MARK: - UI Elements
    private lazy var textFieldContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fill
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = .ypBackgroundDay
        textField.autocorrectionType = .no
        textField.delegate = self
        textField.clearButtonMode = .never
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        let clearButton = UIButton(type: .system)
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.tintColor = .ypGray
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        clearButton.isHidden = true
        
        let clearButtonContainer = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 40))
        clearButton.frame = CGRect(x: 12, y: 10, width: 20, height: 20)
        clearButtonContainer.addSubview(clearButton)
        
        textField.rightView = clearButtonContainer
        textField.rightViewMode = .whileEditing
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var optionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = .ypBackgroundDay
        tableView.separatorColor = .ypGray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.ypWhiteDay, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Initialization
    init(type: TrackerType) {
        self.type = type
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
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .ypWhiteDay
        title = type == .habit ? "Новая привычка" : "Новое событие"
        
        textFieldContainer.addArrangedSubview(titleTextField)
        textFieldContainer.addArrangedSubview(errorLabel)
        
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(saveButton)
        
        view.addSubviews(textFieldContainer, optionsTableView, buttonsStackView)
    }
    
    private func setupConstraints() {
        textFieldContainer.pin
            .top(view.safeAreaLayoutGuide.topAnchor, offset: 24)
            .leading(view.leadingAnchor, offset: 16)
            .trailing(view.trailingAnchor, offset: -16)
        
        optionsTableView.pin
            .top(textFieldContainer.bottomAnchor, offset: 24)
            .leading(view.leadingAnchor, offset: 16)
            .trailing(view.trailingAnchor, offset: -16)
            .height(CGFloat(options.count * 75))
        
        buttonsStackView.pin
            .bottom(view.safeAreaLayoutGuide.bottomAnchor, offset: -16)
            .leading(view.leadingAnchor, offset: 20)
            .trailing(view.trailingAnchor, offset: -20)
            .height(60)
        
        titleTextField.pin.height(75)
        cancelButton.pin.height(60)
        saveButton.pin.height(60)
    }
    
    // MARK: - Actions
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if let clearButtonContainer = textField.rightView,
           let clearButton = clearButtonContainer.subviews.first as? UIButton {
            clearButton.isHidden = text.isEmpty
        }
        
        if text.count > 38 {
            errorLabel.isHidden = false
            textField.text = String(text.prefix(38))
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else {
            errorLabel.isHidden = true
        }
        
        trackerTitle = textField.text ?? ""
        updateSaveButtonState()
    }
    
    @objc private func clearTextField() {
        titleTextField.text = ""
        trackerTitle = ""
        errorLabel.isHidden = true
        
        if let clearButtonContainer = titleTextField.rightView,
           let clearButton = clearButtonContainer.subviews.first as? UIButton {
            clearButton.isHidden = true
        }
        
        updateSaveButtonState()
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc private func didTapSave() {
        let tracker = Tracker(
            id: UUID(),
            title: trackerTitle,
            color: .ypBlue,
            emoji: "🛠️",
            schedule: type == .habit ? selectedDays : []
        )
        
        NotificationCenter.default.post(
            name: NSNotification.Name("DidAddNewTracker"),
            object: tracker
        )
        dismiss(animated: true)
    }
    
    private func updateSaveButtonState() {
        let isValid = !trackerTitle.isEmpty && errorLabel.isHidden
        saveButton.isEnabled = isValid
        saveButton.backgroundColor = isValid ? .ypBlackDay : .ypGray
    }
}

// MARK: - UITableViewDataSource
extension AddTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.backgroundColor = .ypBackgroundDay
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        
        cell.textLabel?.text = options[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        
        if indexPath.row == 1 {
            if !selectedDays.isEmpty {
                let sortedDays = selectedDays.sorted(by: { $0.rawValue < $1.rawValue })
                let daysString = sortedDays.map { $0.shortName }.joined(separator: ", ")
                
                cell.detailTextLabel?.text = daysString
                cell.detailTextLabel?.textColor = .ypGray
                cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
            }
        }
        
        if options.count == 1 {
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
        } else {
            switch indexPath.row {
            case 0:
                cell.layer.cornerRadius = 16
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            case options.count - 1:
                cell.layer.cornerRadius = 16
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            default:
                cell.layer.cornerRadius = 0
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - UITableViewDelegate
extension AddTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let alert = UIAlertController(title: "Выбор категории", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "В разработке", style: .default))
            alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel))
            present(alert, animated: true)
            
        case 1:
            let vc = ScheduleViewController(selectedDays: selectedDays)
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if options.count > 1 && indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
    }
}

// MARK: - ScheduleSelectionDelegate
extension AddTrackerViewController: ScheduleSelectionDelegate {
    func didSelectSchedule(_ selectedDays: Set<Weekday>) {
        self.selectedDays = selectedDays
        
        DispatchQueue.main.async {
            self.optionsTableView.reloadRows(
                at: [IndexPath(row: 1, section: 0)],
                with: .automatic
            )
        }
    }
}

// MARK: - UITextFieldDelegate
extension AddTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty,
           let clearButtonContainer = textField.rightView,
           let clearButton = clearButtonContainer.subviews.first as? UIButton {
            clearButton.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let clearButtonContainer = textField.rightView,
           let clearButton = clearButtonContainer.subviews.first as? UIButton {
            clearButton.isHidden = true
        }
    }
}
