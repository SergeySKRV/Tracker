import UIKit
import SnapKit
import AppMetricaCore

// MARK: - CreateCategoryViewController
final class CreateCategoryViewController: UIViewController {
    
    // MARK: - Properties
    var onCategoryCreated: (() -> Void)?
    
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
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Готово", comment: ""), for: .normal)
        button.setTitleColor(.ypWhiteDayNight, for: .normal)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Lifecycle
    init(viewModel: CategoriesViewModel = CategoriesViewModel()) {
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
    
        let openEvent = [
            "event": "open",
            "screen": "CreateCategory"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: openEvent)
        print("Analytics: \(openEvent)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
        let closeEvent = [
            "event": "close",
            "screen": "CreateCategory"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: closeEvent)
        print("Analytics: \(closeEvent)")
    }
    
    // MARK: - Public Methods
    func configure(with title: String) {
        textField.text = title
        textFieldDidChange()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        title = NSLocalizedString("Новая категория", comment: "")
        view.backgroundColor = .ypWhiteDayNight
        view.addSubview(textField)
        view.addSubview(createButton)
        textField.delegate = self
    }
    
    private func setupConstraints() {
        textField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(75)
        }
        
        createButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }
    
    private func setupActions() {
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    // MARK: - Actions
    @objc private func textFieldDidChange() {
        let text = textField.text ?? ""
        createButton.isEnabled = !text.isEmpty
        createButton.backgroundColor = !text.isEmpty ? .ypBlackDayNight : .ypGray
    
        if !text.isEmpty {
            let textEvent = [
                "event": "click",
                "screen": "CreateCategory",
                "item": "text_changed",
                "text_length": text.count
            ] as [String : Any]
            AppMetrica.reportEvent(name: "Screen Event", parameters: textEvent)
            print("Analytics: \(textEvent)")
        }
    }
    
    @objc private func createButtonTapped() {
        guard let title = textField.text, !title.isEmpty else { return }
        
        let createEvent = [
            "event": "click",
            "screen": "CreateCategory",
            "item": "create_category",
            "category_name": title
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: createEvent)
        print("Analytics: \(createEvent)")
        
        viewModel.addCategory(title: title)
        onCategoryCreated?()
        
        NotificationCenter.default.post(
            name: NSNotification.Name("CategoriesDidUpdate"),
            object: nil
        )
        
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CreateCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        let returnEvent = [
            "event": "click",
            "screen": "CreateCategory",
            "item": "return_key"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: returnEvent)
        print("Analytics: \(returnEvent)")
        
        return true
    }
}
