import UIKit
import SnapKit

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
        
        AnalyticsService.shared.reportEvent(AnalyticsEvent(type: .open, screen: .createCategory))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AnalyticsService.shared.reportEvent(AnalyticsEvent(type: .close, screen: .createCategory))
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

    @objc private func textFieldDidChange() {
        let text = textField.text ?? ""
        createButton.isEnabled = !text.isEmpty
        createButton.backgroundColor = !text.isEmpty ? .ypBlackDayNight : .ypGray
        if !text.isEmpty {
            AnalyticsService.shared.reportEvent(AnalyticsEvent(
                type: .click,
                screen: .createCategory,
                item: .textChanged,
                additionalParameters: [
                    "text_length": text.count
                ]
            ))
        }
    }

    @objc private func createButtonTapped() {
        guard let title = textField.text, !title.isEmpty else { return }
      
        AnalyticsService.shared.reportEvent(AnalyticsEvent(
            type: .click,
            screen: .createCategory,
            item: .createCategory,
            additionalParameters: [
                "category_name": title
            ]
        ))
        
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
      
        AnalyticsService.shared.reportEvent(AnalyticsEvent(type: .click, screen: .createCategory, item: .returnKey))
        
        return true
    }
}
