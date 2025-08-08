import UIKit
import SnapKit

// MARK: - CategorySelectionDelegate
protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory)
}

// MARK: - CategoriesViewController
final class CategoriesViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CategoriesViewModel
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let placeholderView = PlaceholderView()
    private let addButton = UIButton(type: .system)
    
    weak var delegate: CategorySelectionDelegate?
    
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
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadCategories()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        title = NSLocalizedString("Категория", comment: "")
        view.backgroundColor = .ypWhiteDayNight
        
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        view.addSubview(tableView)
        
        placeholderView.configure(
            image: UIImage(named: "placeholder"),
            text: NSLocalizedString("Привычки и события можно\nобъединить по смыслу", comment: "")
        )
        view.addSubview(placeholderView)
        
        addButton.setTitle(NSLocalizedString("Добавить категорию", comment: ""), for: .normal)
        addButton.setTitleColor(.ypWhiteDayNight, for: .normal)
        addButton.backgroundColor = .ypBlackDayNight
        addButton.layer.cornerRadius = 16
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addButton.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        view.addSubview(addButton)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(addButton.snp.top).offset(-16)
        }
        
        placeholderView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        addButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(60)
        }
    }
    
    private func setupBindings() {
        viewModel.didUpdateCategories = { [weak self] in
            self?.updateUI()
        }
    }
    
    private func updateUI() {
        let isEmpty = viewModel.numberOfCategories() == 0
        placeholderView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        navigationItem.hidesBackButton = true
        tableView.reloadData()
    }
    
    private func presentEditCategoryViewController(for category: TrackerCategory, at indexPath: IndexPath) {
        let editVC = EditCategoryViewController(category: category, viewModel: viewModel)
        editVC.delegate = self
        let navVC = UINavigationController(rootViewController: editVC)
        present(navVC, animated: true)
    }
    
    private func deleteCategory(at indexPath: IndexPath) {
        let category = viewModel.category(at: indexPath.row)
        
        if !category.trackers.isEmpty {
            let alert = UIAlertController(
                title: NSLocalizedString("Невозможно удалить", comment: ""),
                message: NSLocalizedString("Категория содержит трекеры. Удалите их сначала.", comment: ""),
                preferredStyle: .actionSheet
            )
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true)
            return
        }
        
        let alert = UIAlertController(
            title: NSLocalizedString("Эта категория точно не нужна?", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Отменить", comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Удалить", comment: ""), style: .destructive) { [weak self] _ in
            do {
                try self?.viewModel.deleteCategory(category)
                self?.updateUI()
            } catch {
                let errorAlert = UIAlertController(
                    title: NSLocalizedString("Ошибка", comment: ""),
                    message: NSLocalizedString("Не удалось удалить категорию: \(error.localizedDescription)", comment: ""),
                    preferredStyle: .alert
                )
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(errorAlert, animated: true)
            }
        })
        
        if let popover = alert.popoverPresentationController {
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func addCategoryTapped() {
        let createCategoryVC = CreateCategoryViewController(viewModel: viewModel)
        createCategoryVC.onCategoryCreated = { [weak self] in
            self?.viewModel.loadCategories()
        }
        let navVC = UINavigationController(rootViewController: createCategoryVC)
        present(navVC, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCategories()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell
        else { return UITableViewCell() }
        
        let isLastCell = indexPath.row == viewModel.numberOfCategories() - 1
        cell.configure(
            title: viewModel.categoryTitle(at: indexPath.row),
            isSelected: viewModel.isCategorySelected(at: indexPath.row),
            isFirstCell: indexPath.row == 0,
            isLastCell: isLastCell
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = viewModel.category(at: indexPath.row)
        viewModel.selectCategory(selectedCategory)
        tableView.reloadData()
        delegate?.didSelectCategory(selectedCategory)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let category = viewModel.category(at: indexPath.row)
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: NSLocalizedString("Редактировать", comment: "")) { [weak self] _ in
                self?.presentEditCategoryViewController(for: category, at: indexPath)
            }
            
            let deleteAction = UIAction(title: NSLocalizedString("Удалить", comment: ""), attributes: .destructive) { [weak self] _ in
                self?.deleteCategory(at: indexPath)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}

// MARK: - EditCategoryViewControllerDelegate
extension CategoriesViewController: EditCategoryViewControllerDelegate {
    func didUpdateCategory() {
        viewModel.loadCategories()
        tableView.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name("CategoriesDidUpdate"), object: nil)
    }
}
