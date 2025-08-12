import Foundation
import CoreData

// MARK: - TrackerDataProviderProtocol
protocol TrackerDataProviderProtocol {
    func fetchTrackers(for date: Date, searchText: String, completion: @escaping ([Tracker]) -> Void)
    func addTracker(_ tracker: Tracker, categoryId: UUID) throws
    func fetchCategories() -> [TrackerCategory]
    func addRecord(for trackerID: UUID, date: Date) throws
    func deleteRecord(for trackerID: UUID, date: Date) throws
    func fetchRecords() -> [TrackerRecord]
    func deleteTracker(_ tracker: Tracker) throws
    func updateTracker(_ tracker: Tracker, categoryId: UUID) throws
    func getAllTrackers() -> [Tracker]
    func getCategoryTitle(by id: UUID) -> String?
    func setTrackerStoreDelegate(_ delegate: TrackerStoreDelegate?)
}

// MARK: - TrackerDataProvider
final class TrackerDataProvider: TrackerDataProviderProtocol {

    // MARK: - Static Constants
    static let shared = TrackerDataProvider()

    // MARK: - Properties
    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore

    // MARK: - Lifecycle
    private init(
        context: NSManagedObjectContext = CoreDataStack.shared.viewContext,
        trackerStore: TrackerStore = TrackerStore(context: CoreDataStack.shared.viewContext),
        categoryStore: TrackerCategoryStore = TrackerCategoryStore(context: CoreDataStack.shared.viewContext),
        recordStore: TrackerRecordStore = TrackerRecordStore(context: CoreDataStack.shared.viewContext)
    ) {
        self.context = context
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
    }

    // MARK: - Public Methods
    func setTrackerStoreDelegate(_ delegate: TrackerStoreDelegate?) {
        trackerStore.delegate = delegate
    }

    func getAllTrackers() -> [Tracker] {
        return trackerStore.fetchTrackers()
    }

    func fetchTrackers(for date: Date, searchText: String, completion: @escaping ([Tracker]) -> Void) {
        DispatchQueue.global().async {
            let calendar = Calendar.current
            let dayOfWeek = calendar.component(.weekday, from: date)
            let weekDayIndex: Int
            switch dayOfWeek {
            case 1: weekDayIndex = 6
            case 2: weekDayIndex = 0
            case 3: weekDayIndex = 1
            case 4: weekDayIndex = 2
            case 5: weekDayIndex = 3
            case 6: weekDayIndex = 4
            case 7: weekDayIndex = 5
            default: weekDayIndex = 0
            }

            guard let weekday = Weekday(rawValue: weekDayIndex) else {
                completion([])
                return
            }

            let categories = self.categoryStore.fetchAllCategories()
            let filteredTrackers = categories.flatMap { category in
                category.trackers.filter { tracker in
                    let isEvent = tracker.schedule.isEmpty
                    let isHabitForToday = !tracker.schedule.isEmpty && tracker.schedule.contains(weekday)
                    let dayMatches = isEvent || isHabitForToday
                    let searchMatches = searchText.isEmpty || tracker.title.localizedCaseInsensitiveContains(searchText)
                    return dayMatches && searchMatches
                }
            }

            DispatchQueue.main.async {
                completion(filteredTrackers)
            }
        }
    }

    func addTracker(_ tracker: Tracker, categoryId: UUID) throws {
        try trackerStore.addTracker(tracker, to: categoryId)
    }

    func updateTracker(_ tracker: Tracker, categoryId: UUID) throws {
        try trackerStore.updateTracker(tracker, categoryId: categoryId)
    }

    func deleteTracker(_ tracker: Tracker) throws {
        try trackerStore.deleteTracker(tracker)
    }

    func fetchCategories() -> [TrackerCategory] {
        return categoryStore.fetchAllCategories()
    }

    func addRecord(for trackerID: UUID, date: Date) throws {
        try recordStore.addRecord(TrackerRecord(trackerID: trackerID, date: date))
    }

    func deleteRecord(for trackerID: UUID, date: Date) throws {
        try recordStore.deleteRecord(for: trackerID, date: date)
    }

    func fetchRecords() -> [TrackerRecord] {
        return recordStore.fetchRecords()
    }

    func getCategoryTitle(by id: UUID) -> String? {
        return categoryStore.getCategoryTitle(by: id)
    }
}
