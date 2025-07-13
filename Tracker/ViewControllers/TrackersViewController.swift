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

    // MARK: - Initialization
    init(dataProvider: TrackerDataProviderProtocol = TrackerDataProvider()) {
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           tapGesture.cancelsTouchesInView = false
           view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackersUpdate),
            name: NSNotification.Name("TrackersUpdated"),
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteDay
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(plugText)
        view.addSubviews(addTrackerButton, trackersLabel, datePicker, searchBar, collectionView, placeholderStackView)
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
        placeholderStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
        }
        placeholderImageView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }
    }

    private func loadInitialData() {
        let categories = dataProvider.fetchCategories()
        if categories.isEmpty {
            do {
                _ = try dataProvider.getDefaultCategory()
            } catch {
                print("Ошибка получения категории по умолчанию: \(error)")
            }
        }
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

    @objc private func handleTrackersUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.updateVisibleTrackers()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Data Processing
    private func updateVisibleTrackers() {
        dataProvider.fetchTrackers(for: currentDate, searchText: searchText) { [weak self] trackers in
            guard let self = self else { return }

            let grouped = Dictionary(grouping: trackers, by: { $0.category?.title ?? "Без категории" })

            let sortedKeys = grouped.keys.sorted()
            self.filteredCategories = sortedKeys.map { key in
                TrackerCategory(title: key, trackers: grouped[key] ?? [])
            }

            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.updateStubVisibility()
            }
        }
    }

    private func updateStubVisibility() {
        let hasTrackers = !filteredCategories.isEmpty
        collectionView.isHidden = !hasTrackers
        UIView.animate(withDuration: 0.3) {
            self.placeholderStackView.alpha = hasTrackers ? 0 : 1
            self.placeholderStackView.transform = hasTrackers ?
            CGAffineTransform(scaleX: 0.9, y: 0.9) : .identity
        }
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

