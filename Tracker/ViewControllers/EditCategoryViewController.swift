import UIKit
import SnapKit
import AppMetricaCore

// MARK: - EditCategoryViewControllerDelegate
protocol EditCategoryViewControllerDelegate: AnyObject {
    func didUpdateCategory()
}

// MARK: - EditCategoryViewController
final class EditCategoryViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: EditCategoryViewControllerDelegate?
    
    private let category: TrackerCategory
    private let viewModel: CategoriesViewModel
    
    private let textField: UITextField = {
        let field = UITextField()
        field.placeholder = NSLocalizedString("Введите название категории", comment: "")
        field.backgroundColor = .ypBackground
        field.layer.cornerRadius = 16
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
        field.leftViewMode = .always
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .done
        return field
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Готово", comment: ""), for: .normal)
        button.setTitleColor(.ypWhiteDayNight, for: .normal)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Lifecycle
    init(category: TrackerCategory, viewModel: CategoriesViewModel) {
        self.category = category
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
        setupActions()
        configureUI()
        setupNavigation()
        let openEvent = [
            "event": "open",
            "screen": "EditCategory",
            "category_name": category.title
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: openEvent)
        print("Analytics: \(openEvent)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let closeEvent = [
            "event": "close",
            "screen": "EditCategory",
            "category_name": category.title
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: closeEvent)
        print("Analytics: \(closeEvent)")
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        title = NSLocalizedString("Редактирование категории", comment: "")
        view.backgroundColor = .ypWhiteDayNight
        view.addSubview(textField)
        view.addSubview(saveButton)
        textField.delegate = self
    }
    
    private func setupConstraints() {
        textField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(75)
        }
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupNavigation() {
        navigationItem.hidesBackButton = true
    }
    
    private func configureUI() {
        textField.text = category.title
        updateSaveButtonState()
    }
    
    private func updateSaveButtonState() {
        let text = textField.text ?? ""
        let hasChanges = text != category.title
        let isUnique = !viewModel.getAllCategories().contains { $0.title == text && $0.id != category.id }
        saveButton.isEnabled = !text.isEmpty && hasChanges && isUnique
        saveButton.backgroundColor = saveButton.isEnabled ? .ypBlackDayNight : .ypGray
    }
    
    @objc private func textFieldDidChange() {
        updateSaveButtonState()
        let text = textField.text ?? ""
        let textEvent = [
            "event": "click",
            "screen": "EditCategory",
            "item": "text_changed",
            "text_length": text.count,
            "has_changes": text != category.title
        ] as [String : Any]
        AppMetrica.reportEvent(name: "Screen Event", parameters: textEvent)
        print("Analytics: \(textEvent)")
    }
    
    @objc private func saveButtonTapped() {
        guard let newTitle = textField.text, !newTitle.isEmpty else { return }
        if viewModel.hasCategory(with: newTitle, excludingId: category.id) {
            let duplicateEvent = [
                "event": "click",
                "screen": "EditCategory",
                "item": "duplicate_category",
                "category_name": newTitle
            ]
            AppMetrica.reportEvent(name: "Screen Event", parameters: duplicateEvent)
            print("Analytics: \(duplicateEvent)")
            showAlert(title: NSLocalizedString("Ошибка", comment: ""), message: NSLocalizedString("Категория с таким названием уже существует", comment: ""))
            return
        }
        let saveEvent = [
            "event": "click",
            "screen": "EditCategory",
            "item": "save_category",
            "old_name": category.title,
            "new_name": newTitle
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: saveEvent)
        print("Analytics: \(saveEvent)")
        do {
            try viewModel.updateCategory(category, with: newTitle)
            delegate?.didUpdateCategory()
            dismiss(animated: true)
        } catch {
            showAlert(title: NSLocalizedString("Ошибка", comment: ""), message: NSLocalizedString("Не удалось обновить категорию", comment: ""))
            AppMetrica.reportEvent(name: "Category Update Failed", parameters: [
                "error": error.localizedDescription,
                "category_name": newTitle
            ])
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension EditCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let returnEvent = [
            "event": "click",
            "screen": "EditCategory",
            "item": "return_key"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: returnEvent)
        print("Analytics: \(returnEvent)")
        return true
    }
}
