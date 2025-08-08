import UIKit
import SnapKit
import AppMetricaCore

// MARK: - TrackersViewController
final class TrackersViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: TrackersViewModelProtocol

    private lazy var addTrackerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .ypBlackDayNight
        button.addTarget(self, action: #selector(didTapAddTrackerButton), for: .touchUpInside)
        return button
    }()

    private lazy var trackersLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Трекеры", comment: "")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlackDayNight
        return label
    }()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return picker
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = NSLocalizedString("Поиск", comment: "")
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.clearButtonMode = .whileEditing
        return searchBar
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInsetReference = .fromSafeArea
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .ypWhiteDayNight
     
        collectionView.alwaysBounceVertical = true
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        collectionView.register(
            TrackerCategoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    private lazy var mainPlaceholderView: PlaceholderView = {
        let view = PlaceholderView()
        view.isHidden = true
        return view
    }()

    private lazy var filterButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = NSLocalizedString("Фильтры", comment: "")
   
        config.baseBackgroundColor = .ypBlue
        config.baseForegroundColor = .ypWhiteDayNight
        let font = UIFont.systemFont(ofSize: 17, weight: .regular)
        let attributedTitle = AttributedString(NSLocalizedString("Фильтры", comment: ""), attributes: AttributeContainer([NSAttributedString.Key.font: font]))
        config.attributedTitle = attributedTitle
        config.cornerStyle = .medium
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    // MARK: - Lifecycle
    init(viewModel: TrackersViewModelProtocol) {
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
        bindViewModel()
     
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataChanged),
            name: NSNotification.Name("TrackerDataChanged"),
            object: nil
        )
        
        let openEvent = [
            "event": "open",
            "screen": "Main"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: openEvent)
        print("Analytics: \(openEvent)")
    }

    @objc private func handleDataChanged() {
        viewModel.updateVisibleCategories()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let closeEvent = [
            "event": "close",
            "screen": "Main"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: closeEvent)
        print("Analytics: \(closeEvent)")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewModel.updateVisibleCategories()
        }
    }

    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteDayNight
        view.addSubviews(
            addTrackerButton,
            trackersLabel,
            datePicker,
            searchBar,
            collectionView,
            mainPlaceholderView
        )

        view.addSubview(filterButton)
        updateStubVisibility()
    }

    private func setupConstraints() {
        addTrackerButton.snp.makeConstraints { make in
            make.width.height.equalTo(42)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(1)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(6)
        }

        trackersLabel.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(16)
            make.top.equalTo(addTrackerButton.snp.bottom).offset(1)
        }

        datePicker.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-16)
            make.width.equalTo(101)
        }

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(trackersLabel.snp.bottom).offset(7)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(8)
            make.height.equalTo(36)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(34)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        mainPlaceholderView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }

        filterButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.width.equalTo(114)
            make.height.equalTo(50)
        }
    }

    private func bindViewModel() {
        viewModel.onDataUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.updateStubVisibility()
                self?.updateFilterButtonVisibility()
                self?.updateFilterButtonColor()
                self?.datePicker.setDate(self?.viewModel.currentDate ?? Date(), animated: true)
            }
        }

        viewModel.onFilterChanged = { [weak self] in
            self?.viewModel.updateVisibleCategories()
        }
    }

    private func updateStubVisibility() {
        let hasTrackers = !viewModel.visibleCategories.isEmpty
        let isSearching = !viewModel.searchText.isEmpty

        if !hasTrackers && !isSearching {
            collectionView.isHidden = true
            mainPlaceholderView.configure(
                image: UIImage(named: "placeholder"),
                text: NSLocalizedString("Что будем отслеживать?", comment: "")
            )
            mainPlaceholderView.isHidden = false
        } else if !hasTrackers && isSearching {
            collectionView.isHidden = true
            mainPlaceholderView.configure(
                image: UIImage(named: "placeholder_notfound"),
                text: NSLocalizedString("Ничего не найдено", comment: "")
            )
            mainPlaceholderView.isHidden = false
        } else if !hasTrackers {
            collectionView.isHidden = true
            mainPlaceholderView.configure(
                image: UIImage(named: "placeholder_notfound"),
                text: NSLocalizedString("Ничего не найдено", comment: "")
            )
            mainPlaceholderView.isHidden = false
        } else {
            collectionView.isHidden = false
            mainPlaceholderView.isHidden = true
        }
    }

    private func updateFilterButtonVisibility() {
        filterButton.isHidden = !viewModel.hasTrackersOnSelectedDate
    }

    private func updateFilterButtonColor() {
        let textColor: UIColor = viewModel.isFilterActive ? .ypRed : .ypWhiteDayNight
        
        var config = filterButton.configuration
        config?.baseForegroundColor = textColor
        filterButton.configuration = config
    }

    private func presentEditTrackerViewController(for tracker: Tracker) {
        let categoryTitle = viewModel.getCategoryTitle(for: tracker.category ?? UUID()) ?? ""
        
        let editVC = EditTrackerViewController(
            tracker: tracker,
            categoryTitle: categoryTitle,
            dataProvider: TrackerDataProvider.shared
        )
        let navVC = UINavigationController(rootViewController: editVC)
        present(navVC, animated: true)
    }

    private func confirmDeleteTracker(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: NSLocalizedString("Удалить трекер", comment: ""),
            message: NSLocalizedString("Уверены что хотите удалить трекер?", comment: ""),
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Удалить", comment: ""), style: .destructive) { [weak self] _ in
    
            let deleteEvent = [
                "event": "click",
                "screen": "Main",
                "item": "delete"
            ]
            AppMetrica.reportEvent(name: "Screen Event", parameters: deleteEvent)
            print("Analytics: \(deleteEvent)")
            
            self?.viewModel.deleteTracker(tracker) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.viewModel.updateVisibleCategories()
                        break
                    case .failure(let error):
                    
                        AppMetrica.reportEvent(name: "Tracker Deletion Failed", parameters: [
                            "error": error.localizedDescription,
                            "tracker_id": tracker.id.uuidString
                        ])
                    }
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Отмена", comment: ""), style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func didTapAddTrackerButton() {

        let addTrackEvent = [
            "event": "click",
            "screen": "Main",
            "item": "add_track"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: addTrackEvent)
        print("Analytics: \(addTrackEvent)")
        
        let typeVC = TrackerTypeViewController()
        typeVC.delegate = self
        let navVC = UINavigationController(rootViewController: typeVC)
        present(navVC, animated: true)
    }

    @objc private func didTapFilterButton() {

        let filterEvent = [
            "event": "click",
            "screen": "Main",
            "item": "filter"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: filterEvent)
        print("Analytics: \(filterEvent)")
        
        let allFilters = TrackersViewModel.FilterType.allCases
        let filterVC = FilterViewController(currentFilter: viewModel.currentFilter, allFilters: allFilters)
        filterVC.delegate = self

        let navVC = UINavigationController(rootViewController: filterVC)
        navVC.modalPresentationStyle = .pageSheet

        present(navVC, animated: true)
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        viewModel.updateCurrentDate(sender.date)
    }
}

// MARK: - TrackerTypeViewControllerDelegate
extension TrackersViewController: TrackerTypeViewControllerDelegate {
    func trackerTypeViewControllerDidCreateTracker(_ controller: TrackerTypeViewController) {
        viewModel.updateVisibleCategories()
    }
}

// MARK: - FilterViewControllerDelegate
extension TrackersViewController: FilterViewControllerDelegate {
    func filterViewController(_ controller: FilterViewController, didSelect filter: TrackersViewModel.FilterType) {
        controller.dismiss(animated: true) {
            self.viewModel.currentFilter = filter
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.visibleCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let tracker = viewModel.visibleCategories[indexPath.section].trackers[indexPath.row]
        let isCompleted = viewModel.isTrackerCompleted(tracker.id, for: viewModel.currentDate)
        let totalCompletions = viewModel.getTotalCompletionCount(for: tracker.id)

        cell.configure(
            with: tracker,
            isCompleted: isCompleted,
            completionCount: totalCompletions,
            selectedDate: viewModel.currentDate
        )

        cell.onCheckButtonTapped = { [weak self] in
       
            let trackEvent = [
                "event": "click",
                "screen": "Main",
                "item": "track"
            ]
            AppMetrica.reportEvent(name: "Screen Event", parameters: trackEvent)
            print("Analytics: \(trackEvent)")
            
            self?.viewModel.toggleTrackerCompletion(tracker, for: self?.viewModel.currentDate ?? Date())
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "header",
            for: indexPath
        ) as? TrackerCategoryHeaderView else {
            return UICollectionReusableView()
        }

        let category = viewModel.visibleCategories[indexPath.section]
        header.configure(with: category.title)
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingWidth = ViewConstants.sidesIndent * 2 + ViewConstants.interitemSpacing * (ViewConstants.columnsCount - 1)
        let availableWidth = collectionView.frame.width - paddingWidth
        let cellWidth = availableWidth / ViewConstants.columnsCount
        return CGSize(width: cellWidth, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 19)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        ViewConstants.interitemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: ViewConstants.sidesIndent, bottom: 16, right: ViewConstants.sidesIndent)
    }
}

// MARK: - UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.updateSearchText(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tracker = viewModel.visibleCategories[indexPath.section].trackers[indexPath.row]
   
        let trackEvent = [
            "event": "click",
            "screen": "Main",
            "item": "track"
        ]
        AppMetrica.reportEvent(name: "Screen Event", parameters: trackEvent)
        print("Analytics: \(trackEvent)")
        
        viewModel.toggleTrackerCompletion(tracker, for: viewModel.currentDate)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = viewModel.visibleCategories[indexPath.section].trackers[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let isPinned = tracker.isPinned
            let pinAction = UIAction(title: isPinned ? NSLocalizedString("Открепить", comment: "") : NSLocalizedString("Закрепить", comment: "")) { [weak self] _ in
                self?.viewModel.togglePinStatus(for: tracker)
                // Обновляем данные после изменения закрепления
                self?.viewModel.updateVisibleCategories()
            }
            let editAction = UIAction(title: NSLocalizedString("Редактировать", comment: "")) { [weak self] _ in
    
                let editEvent = [
                    "event": "click",
                    "screen": "Main",
                    "item": "edit"
                ]
                AppMetrica.reportEvent(name: "Screen Event", parameters: editEvent)
                print("Analytics: \(editEvent)")
                
                self?.presentEditTrackerViewController(for: tracker)
            }
            let deleteAction = UIAction(title: NSLocalizedString("Удалить", comment: ""), attributes: .destructive) { [weak self] _ in
                self?.confirmDeleteTracker(tracker)
            }
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
}
