import UIKit
import SnapKit

// MARK: - TrackersViewController
final class TrackersViewController: UIViewController {
    // MARK: - Properties
    private let dataProvider: TrackerDataProviderProtocol
    private var filteredCategories: [TrackerCategory] = []
    private var searchText: String = ""
    private var currentDate = Date()
    
    // MARK: - UI Elements
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .plus), for: .normal)
        button.tintColor = .ypBlackDay
        button.addTarget(self, action: #selector(didTapAddTrackerButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var trackersLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlackDay
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.clearButtonMode = .whileEditing
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .ypWhiteDay
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
    
    // MARK: - Initialization
    init(dataProvider: TrackerDataProviderProtocol = TrackerDataProvider.shared) {
        self.dataProvider = dataProvider
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
        loadInitialData()
        
        dataProvider.setTrackerStoreDelegate(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteDay
        view.addSubviews(addTrackerButton, trackersLabel, datePicker, searchBar, collectionView, mainPlaceholderView)
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
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        mainPlaceholderView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func loadInitialData() {
        updateVisibleTrackers()
    }
    
    // MARK: - Actions
    @objc private func didTapAddTrackerButton() {
        let typeVC = TrackerTypeViewController()
        let navVC = UINavigationController(rootViewController: typeVC)
        present(navVC, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateVisibleTrackers()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Data Processing
    private func updateVisibleTrackers() {
        let allTrackers = fetchAllTrackersFromStore()
        
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: currentDate)
        let weekDayIndex = dayOfWeek == 1 ? 6 : dayOfWeek - 2
        guard let weekday = Weekday(rawValue: weekDayIndex) else { return }
        
        let filteredTrackers = allTrackers.filter { tracker in
            let isEvent = tracker.schedule.isEmpty
            let isHabitForToday = !tracker.schedule.isEmpty && tracker.schedule.contains(weekday)
            let dayMatches = isEvent || isHabitForToday
            let searchMatches = searchText.isEmpty || tracker.title.localizedCaseInsensitiveContains(searchText)
            return dayMatches && searchMatches
        }
        
        var categoriesDict: [UUID: TrackerCategory] = [:]
        for tracker in filteredTrackers {
            guard let categoryId = tracker.category else { continue }
            
            if let category = categoriesDict[categoryId] {
                var updatedTrackers = category.trackers
                updatedTrackers.append(tracker)
                categoriesDict[categoryId] = TrackerCategory(
                    id: categoryId,
                    title: category.title,
                    trackers: updatedTrackers
                )
            } else {
                if let title = dataProvider.getCategoryTitle(by: categoryId) {
                    categoriesDict[categoryId] = TrackerCategory(
                        id: categoryId,
                        title: title,
                        trackers: [tracker]
                    )
                }
            }
        }
        self.filteredCategories = categoriesDict.values.sorted { $0.title < $1.title }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.updateStubVisibility()
        }
    }
    
    private func fetchAllTrackersFromStore() -> [Tracker] {
        return dataProvider.getAllTrackers()
    }
    
    private func updateStubVisibility() {
        let hasTrackers = !filteredCategories.isEmpty
        let isSearching = !searchText.isEmpty
        
        if !hasTrackers && !isSearching {
            collectionView.isHidden = true
            mainPlaceholderView.configure(
                image: UIImage(named: "placeholder"),
                text: "Что будем отслеживать?"
            )
            mainPlaceholderView.isHidden = false
            return
        }
        
        if !hasTrackers && isSearching {
            collectionView.isHidden = true
            mainPlaceholderView.configure(
                image: UIImage(named: "placeholder_notfound"),
                text: "Ничего не найдено"
            )
            mainPlaceholderView.isHidden = false
            return
        }
        
        collectionView.isHidden = false
        mainPlaceholderView.isHidden = true
    }
    
    private func isTrackerCompleted(_ trackerID: UUID, for date: Date) -> Bool {
        let calendar = Calendar.current
        let selectedStart = calendar.startOfDay(for: date)
        return dataProvider.fetchRecords().contains { record in
            let recordStart = calendar.startOfDay(for: record.date)
            return record.trackerID == trackerID && recordStart == selectedStart
        }
    }
    
    private func getTotalCompletionCount(for trackerID: UUID) -> Int {
        return dataProvider.fetchRecords().filter { $0.trackerID == trackerID }.count
    }
    
    private func toggleTrackerCompletion(at indexPath: IndexPath) {
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        let selectedDate = currentDate
        if isTrackerCompleted(tracker.id, for: selectedDate) {
            try? dataProvider.deleteRecord(for: tracker.id, date: selectedDate)
        } else if selectedDate <= Date() {
            try? dataProvider.addRecord(for: tracker.id, date: selectedDate)
        }
        collectionView.reloadItems(at: [indexPath])
    }
    
    private func togglePinStatus(for tracker: Tracker, at indexPath: IndexPath) {
        let updatedTracker = Tracker(
            id: tracker.id,
            title: tracker.title,
            color: tracker.color,
            emoji: tracker.emoji,
            schedule: tracker.schedule,
            isPinned: !tracker.isPinned,
            categoryId: tracker.category
        )
        
        do {
            try dataProvider.updateTracker(updatedTracker, categoryId: tracker.category ?? UUID())
            
            collectionView.reloadItems(at: [indexPath])
            
        } catch {
            showAlert(title: "Ошибка", message: "Не удалось изменить закрепление")
        }
    }
    
    private func confirmDeleteTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Удалить трекер",
            message: "Уверены что хотите удалить трекер?",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            do {
                try self?.dataProvider.deleteTracker(tracker)
            } catch {
                self?.showAlert(title: "Ошибка", message: "Не удалось удалить трекер")
            }
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func presentEditTrackerViewController(for tracker: Tracker, at indexPath: IndexPath) {
        let editVC = EditTrackerViewController(tracker: tracker)
        let navVC = UINavigationController(rootViewController: editVC)
        present(navVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func didUpdateTrackers() {
        updateVisibleTrackers()
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        let isCompleted = isTrackerCompleted(tracker.id, for: currentDate)
        let totalCompletions = getTotalCompletionCount(for: tracker.id)
        cell.configure(
            with: tracker,
            isCompleted: isCompleted,
            completionCount: totalCompletions,
            selectedDate: currentDate
        )
        cell.onCheckButtonTapped = { [weak self] in
            self?.toggleTrackerCompletion(at: indexPath)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "header",
            for: indexPath
        ) as? TrackerCategoryHeaderView else {
            return UICollectionReusableView()
        }
        headerView.configure(with: filteredCategories[indexPath.section].title)
        return headerView
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
        self.searchText = searchText.lowercased()
        updateVisibleTrackers()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        toggleTrackerCompletion(at: indexPath)
    }
    
    // MARK: - Context Menu
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { _ in
            let isPinned = tracker.isPinned
            
            let pinAction = UIAction(
                title: isPinned ? "Открепить" : "Закрепить",
            ) { [weak self] _ in
                self?.togglePinStatus(for: tracker, at: indexPath)
            }
            
            let editAction = UIAction(
                title: "Редактировать",
            ) { [weak self] _ in
                self?.presentEditTrackerViewController(for: tracker, at: indexPath)
            }
            
            let deleteAction = UIAction(
                title: "Удалить",
                attributes: .destructive
            ) { [weak self] _ in
                self?.confirmDeleteTracker(tracker, at: indexPath)
            }
            
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
}
