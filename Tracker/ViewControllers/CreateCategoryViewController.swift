import UIKit
import SnapKit

final class CreateCategoryViewController: UIViewController {
    // MARK: - Properties
    var onCategoryCreated: (() -> Void)?
    private let viewModel: CategoriesViewModel
    
    // MARK: - UI Elements
    private let textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название категории"
        field.backgroundColor = .ypBackgroundDay
        field.layer.cornerRadius = 16
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
        field.leftViewMode = .always
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .done
        return field
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhiteDay, for: .normal)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Initialization
    init(viewModel: CategoriesViewModel = CategoriesViewModel()) {
        self.viewModel = viewModel
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
        setupActions()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "Новая категория"
        view.backgroundColor = .ypWhiteDay
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
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(60)
        }
    }
    
    private func setupActions() {
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    // MARK: - Public Methods
    func configure(with title: String) {
        textField.text = title
        textFieldDidChange() 
    }
    
    // MARK: - Actions
    @objc private func textFieldDidChange() {
        let text = textField.text ?? ""
        createButton.isEnabled = !text.isEmpty
        createButton.backgroundColor = !text.isEmpty ? .ypBlackDay : .ypGray
    }
    
    @objc private func createButtonTapped() {
        guard let title = textField.text, !title.isEmpty else { return }
        viewModel.addCategory(title: title)
        onCategoryCreated?()
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CreateCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
