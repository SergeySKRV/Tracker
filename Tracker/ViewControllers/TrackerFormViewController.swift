import UIKit
import SnapKit
import AppMetricaCore

// MARK: - TrackerFormDelegate
protocol TrackerFormDelegate: AnyObject {
    func didRequestSave(
        title: String,
        emoji: String,
        color: UIColor,
        schedule: Set<Weekday>,
        categoryId: UUID
    )
    func didRequestCancel()
}

// MARK: - TrackerFormViewController
final class TrackerFormViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel: TrackerFormViewModelProtocol!
    var selectedCategoryTitle: String?
    var daysCountLabel: UILabel?
    weak var delegate: TrackerFormDelegate?
    
    // MARK: - UI Elements
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    lazy var contentView: UIView = UIView()
    
    lazy var textFieldContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = TrackerConstants.Layout.smallSpacing
        return stack
    }()
    
    lazy var titleTextField: UITextField = {
        let field = UITextField()
        field.placeholder = TrackerConstants.Text.trackerNamePlaceholder
        field.font = UIFont.systemFont(ofSize: 17)
        field.backgroundColor = .ypBackground
        field.layer.cornerRadius = TrackerConstants.Layout.cornerRadius
        field.layer.masksToBounds = true
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
        field.leftViewMode = .always
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark.circle.fill")
        config.baseForegroundColor = .ypGray
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12)
        let clearButton = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
            self?.titleTextField.text = ""
            self?.textFieldDidChange(self?.titleTextField ?? UITextField())
        })
        field.rightView = clearButton
        field.rightViewMode = .whileEditing
        field.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return field
    }()
    
    lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = TrackerConstants.Text.lengthError
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .ypRed
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    lazy var optionsTableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.isScrollEnabled = false
        table.layer.cornerRadius = TrackerConstants.Layout.cornerRadius
        table.layer.masksToBounds = true
        table.backgroundColor = .ypBackground
        table.separatorColor = .ypGray
        return table
    }()
    
    lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = TrackerConstants.Text.emojiTitle
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.textColor = .ypBlackDayNight
        return label
    }()
    
    lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseIdentifier)
        collection.backgroundColor = .clear
        collection.isScrollEnabled = false
        return collection
    }()
    
    lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.text = TrackerConstants.Text.colorTitle
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.textColor = .ypBlackDayNight
        return label
    }()
    
    lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseIdentifier)
        collection.backgroundColor = .clear
        collection.isScrollEnabled = false
        return collection
    }()
    
    lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = TrackerConstants.Layout.smallSpacing
        stack.distribution = .fillEqually
        return stack
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(TrackerConstants.Text.cancelButton, for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.cornerRadius = TrackerConstants.Layout.cornerRadius
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return button
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(TrackerConstants.Text.createButton, for: .normal)
        button.setTitleColor(.ypWhiteDayNight, for: .normal)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = TrackerConstants.Layout.cornerRadius
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupDelegates()
        navigationItem.setHidesBackButton(true, animated: false)
        titleTextField.inputAssistantItem.leadingBarButtonGroups = []
        titleTextField.inputAssistantItem.trailingBarButtonGroups = []
        titleTextField.autocorrectionType = .no
     
        let screenName = daysCountLabel != nil ? "EditTrackerForm" : "CreateTrackerForm"
        let openEvent = [
            "event": "open",
            "screen": screenName
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: openEvent)
        print("Analytics: \(openEvent)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
        let screenName = daysCountLabel != nil ? "EditTrackerForm" : "CreateTrackerForm"
        let closeEvent = [
            "event": "close",
            "screen": screenName
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: closeEvent)
        print("Analytics: \(closeEvent)")
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteDayNight
        if let daysCountLabel = daysCountLabel {
            contentView.addSubview(daysCountLabel)
        }
        textFieldContainer.addArrangedSubview(titleTextField)
        textFieldContainer.addArrangedSubview(errorLabel)
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(saveButton)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [textFieldContainer, optionsTableView, emojiLabel, emojiCollectionView,
         colorLabel, colorCollectionView, buttonsStackView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupDelegates() {
        optionsTableView.dataSource = self
        optionsTableView.delegate = self
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        titleTextField.delegate = self
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        if let daysCountLabel = daysCountLabel {
            daysCountLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(TrackerConstants.Layout.sectionSpacing)
                make.leading.trailing.equalToSuperview().inset(TrackerConstants.Layout.defaultSpacing)
                make.height.equalTo(38)
            }
            textFieldContainer.snp.makeConstraints { make in
                make.top.equalTo(daysCountLabel.snp.bottom).offset(40)
                make.leading.trailing.equalToSuperview().inset(TrackerConstants.Layout.defaultSpacing)
            }
        } else {
            textFieldContainer.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(TrackerConstants.Layout.sectionSpacing)
                make.leading.trailing.equalToSuperview().inset(TrackerConstants.Layout.defaultSpacing)
            }
        }
        titleTextField.snp.makeConstraints { make in
            make.height.equalTo(75)
        }
        optionsTableView.snp.makeConstraints { make in
            make.top.equalTo(textFieldContainer.snp.bottom).offset(TrackerConstants.Layout.sectionSpacing)
            make.leading.trailing.equalToSuperview().inset(TrackerConstants.Layout.defaultSpacing)
            make.height.equalTo(viewModel.options.count * Int(TrackerConstants.Layout.textFieldHeight))
        }
        emojiLabel.snp.makeConstraints { make in
            make.top.equalTo(optionsTableView.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(28)
        }
        emojiCollectionView.snp.makeConstraints { make in
            make.top.equalTo(emojiLabel.snp.bottom).offset(TrackerConstants.Layout.defaultSpacing)
            make.leading.trailing.equalToSuperview().inset(TrackerConstants.Layout.defaultSpacing)
            make.height.equalTo(TrackerConstants.Layout.collectionHeight)
        }
        colorLabel.snp.makeConstraints { make in
            make.top.equalTo(emojiCollectionView.snp.bottom).offset(TrackerConstants.Layout.defaultSpacing)
            make.leading.equalToSuperview().offset(28)
        }
        colorCollectionView.snp.makeConstraints { make in
            make.top.equalTo(colorLabel.snp.bottom).offset(TrackerConstants.Layout.defaultSpacing)
            make.leading.trailing.equalToSuperview().inset(TrackerConstants.Layout.defaultSpacing)
            make.height.equalTo(TrackerConstants.Layout.collectionHeight)
        }
        buttonsStackView.snp.makeConstraints { make in
            make.top.equalTo(colorCollectionView.snp.bottom).offset(TrackerConstants.Layout.defaultSpacing)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(TrackerConstants.Layout.buttonHeight)
            make.bottom.equalToSuperview().offset(-TrackerConstants.Layout.defaultSpacing)
        }
    }
    
    // MARK: - Actions
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.count > TrackerConstants.maxTitleLength {
            errorLabel.isHidden = false
            textField.text = String(text.prefix(TrackerConstants.maxTitleLength))
        } else {
            errorLabel.isHidden = true
        }
        viewModel.trackerTitle = textField.text ?? ""
        updateSaveButtonState()
     
        let screenName = daysCountLabel != nil ? "EditTrackerForm" : "CreateTrackerForm"
        let textEvent = [
            "event": "click",
            "screen": screenName,
            "item": "title_text_changed",
            "text_length": text.count
        ] as [String : Any]
        AppMetrica.reportEvent(name: "Screen Event", parameters: textEvent)
        print("Analytics: \(textEvent)")
    }
    
    @objc private func didTapSave() {
        guard let emoji = viewModel.selectedEmoji,
              let color = viewModel.selectedColor,
              !viewModel.trackerTitle.isEmpty,
              let categoryId = viewModel.selectedCategoryId else {
            showAlert(title: NSLocalizedString("Ошибка", comment: ""), message: NSLocalizedString("Заполните все поля", comment: ""))
     
            let screenName = daysCountLabel != nil ? "EditTrackerForm" : "CreateTrackerForm"
            let validationEvent = [
                "event": "click",
                "screen": screenName,
                "item": "validation_error",
                "has_emoji": viewModel.selectedEmoji != nil,
                "has_color": viewModel.selectedColor != nil,
                "has_title": !viewModel.trackerTitle.isEmpty,
                "has_category": viewModel.selectedCategoryId != nil
            ] as [String : Any]
            AppMetrica.reportEvent(name: "Screen Event", parameters: validationEvent)
            print("Analytics: \(validationEvent)")
            
            return
        }
     
        let screenName = daysCountLabel != nil ? "EditTrackerForm" : "CreateTrackerForm"
        let saveEvent = [
            "event": "click",
            "screen": screenName,
            "item": "save_button",
            "tracker_title": viewModel.trackerTitle,
            "emoji": emoji,
            "has_schedule": !viewModel.selectedDays.isEmpty
        ] as [String : Any]
        AppMetrica.reportEvent(name: "Screen Event", parameters: saveEvent)
        print("Analytics: \(saveEvent)")
        
        delegate?.didRequestSave(
            title: viewModel.trackerTitle,
            emoji: emoji,
            color: color,
            schedule: viewModel.selectedDays,
            categoryId: categoryId
        )
    }
    
    @objc private func didTapCancel() {
        let screenName = daysCountLabel != nil ? "EditTrackerForm" : "CreateTrackerForm"
        let cancelEvent = [
            "event": "click",
            "screen": screenName,
            "item": "cancel_button"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: cancelEvent)
        print("Analytics: \(cancelEvent)")
        
        delegate?.didRequestCancel()
    }
    
    // MARK: - Private Helpers
    func updateSaveButtonState() {
        saveButton.isEnabled = viewModel.updateSaveButtonState()
        saveButton.backgroundColor = saveButton.isEnabled ? .ypBlackDayNight : .ypGray
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TrackerFormViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.backgroundColor = .ypBackground
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = viewModel.options[indexPath.row]
        cell.textLabel?.textColor = .ypBlackDayNight
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = .ypGray
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = selectedCategoryTitle ?? NSLocalizedString("Не выбрана", comment: "")
        } else if indexPath.row == 1 && !viewModel.selectedDays.isEmpty {
            let sortedDays = viewModel.selectedDays.sorted { $0.rawValue < $1.rawValue }
            cell.detailTextLabel?.text = sortedDays.map { $0.shortName }.joined(separator: ", ")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        TrackerConstants.Layout.textFieldHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.options.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let screenName = daysCountLabel != nil ? "EditTrackerForm" : "CreateTrackerForm"
        var item = ""
        switch indexPath.row {
        case 0:
            item = "select_category"
        case 1:
            item = "select_schedule"
        default:
            item = "select_option_\(indexPath.row)"
        }
        
        let selectEvent = [
            "event": "click",
            "screen": screenName,
            "item": item
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: selectEvent)
        print("Analytics: \(selectEvent)")
        
        if indexPath.row == 0 {
            let categoriesVC = CategoriesViewController(viewModel: CategoriesViewModel())
            categoriesVC.delegate = self
            navigationController?.pushViewController(categoriesVC, animated: true)
        } else if indexPath.row == 1 {
            let scheduleViewModel = ScheduleViewModel(selectedDays: viewModel.selectedDays)
            let scheduleVC = ScheduleViewController(viewModel: scheduleViewModel)
            scheduleVC.delegate = self
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension TrackerFormViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == emojiCollectionView ? TrackerConstants.emojis.count : TrackerConstants.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCell.reuseIdentifier,
                for: indexPath
            ) as? EmojiCell else {
                assertionFailure("Failed to dequeue EmojiCell")
                return UICollectionViewCell()
            }
            let emoji = TrackerConstants.emojis[indexPath.item]
            cell.configure(with: emoji, isSelected: emoji == viewModel.selectedEmoji)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCell.reuseIdentifier,
                for: indexPath
            ) as? ColorCell else {
                assertionFailure("Failed to dequeue ColorCell")
                return UICollectionViewCell()
            }
            let color = TrackerConstants.colors[indexPath.item]
            let isSelected = viewModel.selectedColor?.isEqual(to: color) ?? false
            cell.configure(with: color, isSelected: isSelected)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalInsets = TrackerConstants.Layout.defaultSpacing * 2
        let totalSpacing = TrackerConstants.interItemSpacing * CGFloat(TrackerConstants.columnsCount - 1)
        let availableWidth = collectionView.bounds.width - totalInsets - totalSpacing
        let cellWidth = availableWidth / CGFloat(TrackerConstants.columnsCount)
        return CGSize(width: cellWidth, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        TrackerConstants.interItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(
            top: 0,
            left: TrackerConstants.Layout.defaultSpacing,
            bottom: 0,
            right: TrackerConstants.Layout.defaultSpacing
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let screenName = daysCountLabel != nil ? "EditTrackerForm" : "CreateTrackerForm"
        let item = collectionView == emojiCollectionView ? "select_emoji" : "select_color"
        
        let selectEvent = [
            "event": "click",
            "screen": screenName,
            "item": item
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: selectEvent)
        print("Analytics: \(selectEvent)")
        
        if collectionView == emojiCollectionView {
            viewModel.selectedEmoji = TrackerConstants.emojis[indexPath.item]
        } else {
            viewModel.selectedColor = TrackerConstants.colors[indexPath.item]
        }
        collectionView.reloadData()
        updateSaveButtonState()
    }
}

// MARK: - UITextFieldDelegate
extension TrackerFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        let screenName = daysCountLabel != nil ? "EditTrackerForm" : "CreateTrackerForm"
        let returnEvent = [
            "event": "click",
            "screen": screenName,
            "item": "return_key"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: returnEvent)
        print("Analytics: \(returnEvent)")
        
        return true
    }
}

// MARK: - CategorySelectionDelegate
extension TrackerFormViewController: CategorySelectionDelegate {
    func didSelectCategory(_ category: TrackerCategory) {
        viewModel.selectedCategoryId = category.id
        selectedCategoryTitle = category.title
        optionsTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        updateSaveButtonState()

        let screenName = daysCountLabel != nil ? "EditTrackerForm" : "CreateTrackerForm"
        let categoryEvent = [
            "event": "click",
            "screen": screenName,
            "item": "category_selected",
            "category_name": category.title
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: categoryEvent)
        print("Analytics: \(categoryEvent)")
    }
}

// MARK: - ScheduleSelectionDelegate
extension TrackerFormViewController: ScheduleSelectionDelegate {
    func didSelectSchedule(_ selectedDays: Set<Weekday>) {
        viewModel.selectedDays = selectedDays
        optionsTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
   
        let screenName = daysCountLabel != nil ? "EditTrackerForm" : "CreateTrackerForm"
        let scheduleEvent = [
            "event": "click",
            "screen": screenName,
            "item": "schedule_selected",
            "days_count": selectedDays.count
        ] as [String : Any]
        AppMetrica.reportEvent(name: "Screen Event", parameters: scheduleEvent)
        print("Analytics: \(scheduleEvent)")
    }
}
