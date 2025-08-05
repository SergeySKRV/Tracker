import UIKit

// MARK: - EditTrackerViewModelProtocol
protocol EditTrackerViewModelProtocol: TrackerFormViewModelProtocol {
    var daysCompleted: Int { get }
    func pluralizeDays(count: Int) -> String
    func saveTracker(
        title: String,
        emoji: String,
        color: UIColor,
        schedule: Set<Weekday>,
        categoryId: UUID,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

// MARK: - EditTrackerViewModel
final class EditTrackerViewModel: EditTrackerViewModelProtocol {
    
    // MARK: - Properties
    var trackerTitle: String
    var selectedEmoji: String?
    var selectedColor: UIColor?
    var selectedDays: Set<Weekday>
    var selectedCategoryId: UUID?
    var selectedCategoryTitle: String?
    var options: [String] = []
    
    private let tracker: Tracker
    private let dataProvider: TrackerDataProviderProtocol
    
    var daysCompleted: Int {
        dataProvider.fetchRecords().filter { $0.trackerID == tracker.id }.count
    }
    
    // MARK: - Lifecycle
    init(
        tracker: Tracker,
        categoryTitle: String,
        dataProvider: TrackerDataProviderProtocol = TrackerDataProvider.shared
    ) {
        self.tracker = tracker
        self.dataProvider = dataProvider
        self.trackerTitle = tracker.title
        self.selectedEmoji = tracker.emoji
        self.selectedColor = tracker.color
        self.selectedDays = tracker.schedule
        self.selectedCategoryId = tracker.category
        self.selectedCategoryTitle = dataProvider.getCategoryTitle(by: tracker.category ?? UUID()) ?? categoryTitle
        self.options = tracker.schedule.isEmpty ? ["Категория"] : ["Категория", "Расписание"]
    }
    
    // MARK: - Public Methods
    func updateSaveButtonState() -> Bool {
        return !trackerTitle.isEmpty &&
               selectedEmoji != nil &&
               selectedColor != nil &&
               selectedCategoryId != nil
    }
    
    func pluralizeDays(count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        
        if remainder10 == 1 && remainder100 != 11 {
            return "\(count) день"
        } else if remainder10 >= 2 && remainder10 <= 4 && (remainder100 < 10 || remainder100 >= 20) {
            return "\(count) дня"
        } else {
            return "\(count) дней"
        }
    }
    
    func saveTracker(
        title: String,
        emoji: String,
        color: UIColor,
        schedule: Set<Weekday>,
        categoryId: UUID,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let updatedTracker = Tracker(
            id: tracker.id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule,
            isPinned: tracker.isPinned,
            categoryId: categoryId
        )
        
        do {
            try dataProvider.updateTracker(updatedTracker, categoryId: categoryId)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
