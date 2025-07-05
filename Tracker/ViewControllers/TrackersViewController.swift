import UIKit

// MARK: - Constants
struct ViewConstants {
    static let sidesIndent: CGFloat = 16
    static let interitemSpacing: CGFloat = 9
    static let columnsCount: CGFloat = 2
}

// MARK: - TrackersViewController Class
final class TrackersViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - Properties
    var categories: [TrackerCategory] = []
    var filteredCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    private var searchText: String = ""
    
    // MARK: - UI Elements
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .plus), for: .normal)
        button.tintColor = .ypBlackDay
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
        return collectionView
    }()
    
    private lazy var placeholderStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.alpha = 0
        return stack
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .placeholder))
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var plugText: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        createDefaultCategory()
        addTestTrackers()
        updateVisibleTrackers()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewTracker(_:)),
            name: NSNotification.Name("DidAddNewTracker"),
            object: nil
        )
    }
    
    // MARK: - Initial Setup
    private func createDefaultCategory() {
        if categories.isEmpty {
            let defaultCategory = TrackerCategory(title: "Без категории", trackers: [])
            categories.append(defaultCategory)
        }
    }
    
    private func addTestTrackers() {
        let habitTracker = Tracker(
            id: UUID(),
            title: "Пить воду",
            color: .ypBlue,
            emoji: "💧",
            schedule: Set(Weekday.allCases)
        )
        
        let eventTracker = Tracker(
            id: UUID(),
            title: "Пробежка",
            color: .ypRed,
            emoji: "🏃‍♂️",
            schedule: Set(Weekday.allCases)
        )
        
        if !categories.isEmpty {
            addTracker(habitTracker, to: 0)
            addTracker(eventTracker, to: 0)
        }
    }
    
    // MARK: - Actions
    @objc private func didTapAddTrackerButton() {
        let typeVC = TrackerTypeViewController()
        let navVC = UINavigationController(rootViewController: typeVC)
        navVC.modalPresentationStyle = .automatic
        present(navVC, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        updateVisibleTrackers()
    }
    
    @objc private func handleNewTracker(_ notification: Notification) {
        guard let newTracker = notification.object as? Tracker else { return }
        
        if !categories.isEmpty {
            addTracker(newTracker, to: 0)
        } else {
            let newCategory = TrackerCategory(title: "Без категории", trackers: [newTracker])
            categories.append(newCategory)
        }
        
        updateVisibleTrackers()
    }
    
    @objc private func updateSchedule(_ notification: Notification) {
        guard let selectedDays = notification.object as? Set<Weekday> else { return }
        print("Обновлено расписание: \(selectedDays.map { $0.shortName }.joined(separator: ", "))")
    }
    
    // MARK: - Configure UI
    private func setupUI() {
        view.backgroundColor = .ypWhiteDay
        
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(plugText)
        
        view.addSubviews(addTrackerButton, trackersLabel, datePicker, searchBar, collectionView, placeholderStackView)
        
        addTrackerButton.addTarget(self, action: #selector(didTapAddTrackerButton), for: .touchUpInside)
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        updateStubVisibility()
    }
    
    private func setupConstraints() {
        addTrackerButton.pin
            .width(42)
            .height(42)
            .top(view.safeAreaLayoutGuide.topAnchor, offset: 1)
            .leading(view.safeAreaLayoutGuide.leadingAnchor, offset: 6)
        
        trackersLabel.pin
            .leading(view.safeAreaLayoutGuide.leadingAnchor, offset: 16)
            .top(addTrackerButton.bottomAnchor, offset: 1)
        
        datePicker.pin
            .top(view.safeAreaLayoutGuide.topAnchor, offset: 5)
            .trailing(view.safeAreaLayoutGuide.trailingAnchor, offset: -16)
            .width(101)
        
        searchBar.pin
            .top(trackersLabel.bottomAnchor, offset: 7)
            .leading(view.safeAreaLayoutGuide.leadingAnchor, offset: 8)
            .trailing(view.safeAreaLayoutGuide.trailingAnchor, offset: -8)
            .height(36)
        
        collectionView.pin
            .top(searchBar.bottomAnchor, offset: 34)
            .leading(view.safeAreaLayoutGuide.leadingAnchor)
            .trailing(view.safeAreaLayoutGuide.trailingAnchor)
            .bottom(view.safeAreaLayoutGuide.bottomAnchor)
        
        placeholderStackView.pin
            .top(searchBar.bottomAnchor, offset: 230)
            .centerX(to: view.safeAreaLayoutGuide.centerXAnchor)
        
        placeholderImageView.pin
            .width(80)
            .height(80)
    }
    
    // MARK: - Business Logic
    private func addTracker(_ newTracker: Tracker, to categoryIndex: Int) {
        guard categoryIndex < categories.count else { return }
        
        var updatedCategories = categories
        var targetCategory = updatedCategories[categoryIndex]
        var updatedTrackers = targetCategory.trackers
        updatedTrackers.append(newTracker)
        targetCategory = TrackerCategory(title: targetCategory.title, trackers: updatedTrackers)
        updatedCategories[categoryIndex] = targetCategory
        categories = updatedCategories
    }
    
    // MARK: - Search Logic
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText.lowercased()
        updateVisibleTrackers()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func updateVisibleTrackers() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: datePicker.date)
        let weekdayIndex = (weekday + 5) % 7
        
        guard let currentWeekday = Weekday(rawValue: weekdayIndex) else {
            filteredCategories = []
            collectionView.reloadData()
            updateStubVisibility()
            return
        }
        var result = categories.map { category in
            let filtered = category.trackers.filter {
                let scheduleMatch = $0.schedule.isEmpty || $0.schedule.contains(currentWeekday)
                let searchMatch = searchText.isEmpty || $0.title.lowercased().contains(searchText)
                return scheduleMatch && searchMatch
            }
            return TrackerCategory(title: category.title, trackers: filtered)
        }
        
        result = result.filter { !$0.trackers.isEmpty }
        
        filteredCategories = result
        collectionView.reloadData()
        updateStubVisibility()
    }
    
    private func hasAnyTrackers() -> Bool {
        return !filteredCategories.isEmpty
    }
    
    private func updateStubVisibility() {
        let hasTrackers = hasAnyTrackers()
        collectionView.isHidden = !hasTrackers
        
        if hasTrackers {
            hidePlaceholderWithAnimation()
        } else {
            showPlaceholderWithAnimation()
        }
    }
    
    private func showPlaceholderWithAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.placeholderStackView.alpha = 1
            self.placeholderStackView.transform = .identity
        })
    }
    
    private func hidePlaceholderWithAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.placeholderStackView.alpha = 0
            self.placeholderStackView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
    }
    
    private func isTrackerCompleted(_ trackerID: UUID, for date: Date) -> Bool {
        let calendar = Calendar.current
        let selectedStart = calendar.startOfDay(for: date)
        
        return completedTrackers.contains { record in
            let recordStart = calendar.startOfDay(for: record.date)
            return record.trackerID == trackerID && recordStart == selectedStart
        }
    }
    
    private func getTotalCompletionCount(for trackerID: UUID) -> Int {
        return completedTrackers.filter { $0.trackerID == trackerID }.count
    }
    
    private func canMarkTracker(for date: Date) -> Bool {
        return date <= Date()
    }
    
    private func markTrackerAsCompleted(id: UUID, date: Date) {
        let record = TrackerRecord(trackerID: id, date: date)
        completedTrackers.append(record)
    }
    
    private func unmarkTracker(id: UUID, date: Date) {
        let calendar = Calendar.current
        let selectedStart = calendar.startOfDay(for: date)
        
        completedTrackers.removeAll { record in
            let recordStart = calendar.startOfDay(for: record.date)
            return record.trackerID == id && recordStart == selectedStart
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        let selectedDate = datePicker.date
        
        let isCompleted = isTrackerCompleted(tracker.id, for: selectedDate)
        let totalCompletions = getTotalCompletionCount(for: tracker.id)
        
        cell.configure(
            with: tracker,
            isCompleted: isCompleted,
            completionCount: totalCompletions,
            selectedDate: selectedDate
        )
        
        cell.onCheckButtonTapped = { [weak self] in
            guard let self else { return }
            
            if isCompleted {
                self.unmarkTracker(id: tracker.id, date: selectedDate)
            } else {
                if self.canMarkTracker(for: selectedDate) {
                    self.markTrackerAsCompleted(id: tracker.id, date: selectedDate)
                }
            }
            collectionView.reloadItems(at: [indexPath])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath
              ) as? TrackerCategoryHeaderView else {
            return UICollectionReusableView()
        }
        let category = filteredCategories[indexPath.section]
        headerView.configure(with: category.title)
        
        return headerView
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let paddingWidth = ViewConstants.sidesIndent * 2 + ViewConstants.interitemSpacing * (ViewConstants.columnsCount - 1)
        let availableWidth = collectionView.frame.width - paddingWidth
        let cellWidth = availableWidth / ViewConstants.columnsCount
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ViewConstants.interitemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 12,
            left: ViewConstants.sidesIndent,
            bottom: 16,
            right: ViewConstants.sidesIndent
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 19)
    }
}
