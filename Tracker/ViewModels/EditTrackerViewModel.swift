import Foundation

// MARK: - EditTrackerViewModel
final class EditTrackerViewModel: TrackerFormViewModel {
    // MARK: - Private Properties
    private let tracker: Tracker
    private let dataProvider: TrackerDataProviderProtocol
    
    // MARK: - Lifecycle
    init(
        tracker: Tracker,
        categoryTitle: String,
        dataProvider: TrackerDataProviderProtocol = TrackerDataProvider.shared
    ) {
        self.tracker = tracker
        self.dataProvider = dataProvider
        super.init()
        
        self.trackerTitle = tracker.title
        self.selectedEmoji = tracker.emoji
        self.selectedColor = tracker.color
        self.selectedDays = tracker.schedule
        self.selectedCategoryId = tracker.category
        self.selectedCategoryTitle = dataProvider.getCategoryTitle(by: tracker.category ?? UUID()) ?? categoryTitle
    }
    
    // MARK: - Override Properties
    override var options: [String] {
        !tracker.schedule.isEmpty ? ["Категория", "Расписание"] : ["Категория"]
    }
    
    // MARK: - Computed Properties
    var daysCompleted: Int {
        dataProvider.fetchRecords().filter { $0.trackerID == tracker.id }.count
    }
    
    // MARK: - Public Methods
    func saveTracker(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let emoji = selectedEmoji,
              let color = selectedColor,
              !trackerTitle.isEmpty,
              let categoryId = selectedCategoryId else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Заполните все поля"])))
            return
        }
        
        do {
            try dataProvider.updateTracker(
                Tracker(
                    id: tracker.id,
                    title: trackerTitle,
                    color: color,
                    emoji: emoji,
                    schedule: !tracker.schedule.isEmpty ? selectedDays : [],
                    isPinned: tracker.isPinned,
                    categoryId: categoryId
                ),
                categoryId: categoryId
            )
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Private Helpers
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
}
