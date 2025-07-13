import Foundation
import CoreData

// MARK: - TrackerDataProviderProtocol
protocol TrackerDataProviderProtocol {
    func fetchTrackers(for date: Date, searchText: String, completion: @escaping ([Tracker]) -> Void)
    func addTracker(_ tracker: Tracker, categoryId: UUID?) throws
    func fetchCategories() -> [TrackerCategory]
    func getDefaultCategory() throws -> TrackerCategoryCoreData
    func addRecord(for trackerID: UUID, date: Date) throws
    func deleteRecord(for trackerID: UUID, date: Date) throws
    func fetchRecords() -> [TrackerRecord]
}

// MARK: - TrackerDataProvider
final class TrackerDataProvider: TrackerDataProviderProtocol {

    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore

    init(
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

    // MARK: - Fetch Trackers
    func fetchTrackers(for date: Date, searchText: String, completion: @escaping ([Tracker]) -> Void) {
        DispatchQueue.global().async {
            let calendar = Calendar.current
            guard let weekday = Weekday(rawValue: (calendar.component(.weekday, from: date) + 5) % 7) else {
                completion([])
                return
            }

            let categories = self.categoryStore.fetchCategories()

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

    // MARK: - Add Tracker
    func addTracker(_ tracker: Tracker, categoryId: UUID?) throws {
        try trackerStore.addTracker(tracker, to: categoryId)
    }

    // MARK: - Fetch Categories
    func fetchCategories() -> [TrackerCategory] {
        return categoryStore.fetchCategories()
    }

    // MARK: - Get Default Category
    func getDefaultCategory() throws -> TrackerCategoryCoreData {
        return try categoryStore.getDefaultCategory()
    }

    // MARK: - Records
    func addRecord(for trackerID: UUID, date: Date) throws {
        try recordStore.addRecord(TrackerRecord(trackerID: trackerID, date: date))
    }

    func deleteRecord(for trackerID: UUID, date: Date) throws {
        try recordStore.deleteRecord(for: trackerID, date: date)
    }

    func fetchRecords() -> [TrackerRecord] {
        return recordStore.fetchRecords()
    }
}
