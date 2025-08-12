import UIKit
import SnapKit

// MARK: - TrackersViewModelProtocol
protocol TrackersViewModelProtocol: AnyObject {
    var currentDate: Date { get set }
    var searchText: String { get set }
    var currentFilter: TrackersViewModel.FilterType { get set }
    var visibleCategories: [TrackerCategory] { get }
    var hasTrackersOnSelectedDate: Bool { get }
    var isFilterActive: Bool { get }
    var onFilterChanged: (() -> Void)? { get set }
    var onDataUpdate: (() -> Void)? { get set }
    
    func loadData()
    func updateVisibleCategories()
    func isTrackerCompleted(_ trackerID: UUID, for date: Date) -> Bool
    func getTotalCompletionCount(for trackerID: UUID) -> Int
    func getCategoryTitle(for categoryId: UUID) -> String?
    func toggleTrackerCompletion(_ tracker: Tracker, for date: Date)
    func updateSearchText(_ text: String)
    func updateCurrentDate(_ date: Date)
    func togglePinStatus(for tracker: Tracker)
    func deleteTracker(_ tracker: Tracker, completion: @escaping (Result<Void, Error>) -> Void)
}

// MARK: - TrackersViewModel
final class TrackersViewModel: TrackersViewModelProtocol{

    // MARK: - Filter Type Enum
    enum FilterType: CaseIterable {
        case all
        case today
        case completed
        case incomplete
        
        var title: String {
            switch self {
            case .all: return NSLocalizedString("Все трекеры", comment: "")
            case .today: return NSLocalizedString("Трекеры на сегодня", comment: "")
            case .completed: return NSLocalizedString("Завершённые", comment: "")
            case .incomplete: return NSLocalizedString("Незавершённые", comment: "")
            }
        }
        
        var shouldShowCheckmark: Bool {
            return true
        }
    }

    // MARK: - Properties
    private let dataProvider: TrackerDataProviderProtocol
    private var dataObserver: NSObjectProtocol?
    
    var currentDate = Date()
    var searchText: String = ""
    var currentFilter: FilterType = .all {
        didSet {
            onFilterChanged?()
        }
    }

    var onFilterChanged: (() -> Void)?
    var onDataUpdate: (() -> Void)?

    private var allTrackers: [Tracker] = []
    private var allCategories: [TrackerCategory] = []

    var visibleCategories: [TrackerCategory] = [] {
        didSet {
            onDataUpdate?()
        }
    }

    var hasTrackersOnSelectedDate: Bool {
        allCategories.contains { category in
            category.trackers.contains { tracker in
                let isEvent = tracker.schedule.isEmpty
                let calendar = Calendar.current
                let dayOfWeek = calendar.component(.weekday, from: currentDate)
                let weekDayIndex = dayOfWeek == 1 ? 6 : dayOfWeek - 2
                if let weekday = Weekday(rawValue: weekDayIndex) {
                    let isHabitForToday = !tracker.schedule.isEmpty && tracker.schedule.contains(weekday)
                    return isEvent || isHabitForToday
                }
                return false
            }
        }
    }

    var isFilterActive: Bool {
        switch currentFilter {
        case .all, .today:
            return false
        case .completed, .incomplete:
            return true
        }
    }

    // MARK: - Initialization
    init(dataProvider: TrackerDataProviderProtocol = TrackerDataProvider.shared) {
        self.dataProvider = dataProvider
        
        dataObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSManagedObjectContextDidSave,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.loadData()
        }
        
        loadData()
    }

    deinit {
        if let observer = dataObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Public Methods
    func loadData() {
        allTrackers = dataProvider.getAllTrackers()
        rebuildAllCategories()
        updateVisibleCategories()
    }

    func togglePinStatus(for tracker: Tracker) {
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
            loadData()
        } catch {
            print("Failed to toggle pin status: \(error)")
        }
    }
    
    func updateVisibleCategories() {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: currentDate)
        let weekDayIndex = dayOfWeek == 1 ? 6 : dayOfWeek - 2
        guard let weekday = Weekday(rawValue: weekDayIndex) else {
            visibleCategories = []
            return
        }

        let baseFilteredTrackers = allTrackers.filter { tracker in
            let isEvent = tracker.schedule.isEmpty
            let isHabitForToday = !tracker.schedule.isEmpty && tracker.schedule.contains(weekday)
            let dayMatches = isEvent || isHabitForToday
            let searchMatches = searchText.isEmpty || tracker.title.localizedCaseInsensitiveContains(searchText)
            return dayMatches && searchMatches
        }

        let finalFilteredTrackers: [Tracker] = {
            switch currentFilter {
            case .all, .today:
                return baseFilteredTrackers
            case .completed:
                return baseFilteredTrackers.filter { tracker in
                    isTrackerCompleted(tracker.id, for: currentDate)
                }
            case .incomplete:
                return baseFilteredTrackers.filter { tracker in
                    !isTrackerCompleted(tracker.id, for: currentDate)
                }
            }
        }()

        let pinnedTrackers = finalFilteredTrackers.filter(\.isPinned)
        let unpinnedTrackers = finalFilteredTrackers.filter { !$0.isPinned }

        var resultCategories = [TrackerCategory]()

        if !pinnedTrackers.isEmpty {
            resultCategories.append(TrackerCategory(id: UUID(), title: NSLocalizedString("Закрепленные", comment: ""), trackers: pinnedTrackers))
        }

        var categoriesDict = [UUID: TrackerCategory]()
        for tracker in unpinnedTrackers {
            guard let categoryId = tracker.category else { continue }
            if let existing = categoriesDict[categoryId] {
                var updated = existing.trackers
                updated.append(tracker)
                categoriesDict[categoryId] = TrackerCategory(id: existing.id, title: existing.title, trackers: updated)
            } else if let title = dataProvider.getCategoryTitle(by: categoryId) {
                categoriesDict[categoryId] = TrackerCategory(id: categoryId, title: title, trackers: [tracker])
            }
        }

        let sortedCategories = categoriesDict.values.sorted { $0.title < $1.title }
        resultCategories.append(contentsOf: sortedCategories)

        visibleCategories = resultCategories

        if currentFilter == .today {
            let today = Date()
            if !Calendar.current.isDate(currentDate, inSameDayAs: today) {
                currentDate = today
            }
        }
    }

    func isTrackerCompleted(_ trackerID: UUID, for date: Date) -> Bool {
        let calendar = Calendar.current
        let selectedStart = calendar.startOfDay(for: date)
        return dataProvider.fetchRecords().contains { record in
            let recordStart = calendar.startOfDay(for: record.date)
            return record.trackerID == trackerID && recordStart == selectedStart
        }
    }

    func getTotalCompletionCount(for trackerID: UUID) -> Int {
        dataProvider.fetchRecords().filter { $0.trackerID == trackerID }.count
    }
    
    func getCategoryTitle(for categoryId: UUID) -> String? {
        return dataProvider.getCategoryTitle(by: categoryId)
    }

    func toggleTrackerCompletion(_ tracker: Tracker, for date: Date) {
        if isTrackerCompleted(tracker.id, for: date) {
            try? dataProvider.deleteRecord(for: tracker.id, date: date)
        } else if date <= Date() {
            try? dataProvider.addRecord(for: tracker.id, date: date)
        }
        updateVisibleCategories()
    }

    func updateSearchText(_ text: String) {
        searchText = text.lowercased()
        updateVisibleCategories()
    }

    func updateCurrentDate(_ date: Date) {
        currentDate = date
        updateVisibleCategories()
    }

    func deleteTracker(_ tracker: Tracker, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try dataProvider.deleteTracker(tracker)
            loadData()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - Private Methods
    private func rebuildAllCategories() {
        var categoriesDict = [UUID: TrackerCategory]()
        for tracker in allTrackers {
            guard let categoryId = tracker.category else { continue }
            if let existing = categoriesDict[categoryId] {
                var updated = existing.trackers
                updated.append(tracker)
                categoriesDict[categoryId] = TrackerCategory(id: existing.id, title: existing.title, trackers: updated)
            } else if let title = dataProvider.getCategoryTitle(by: categoryId) {
                categoriesDict[categoryId] = TrackerCategory(id: categoryId, title: title, trackers: [tracker])
            }
        }
        allCategories = categoriesDict.values.sorted { $0.title < $1.title }
    }
}
