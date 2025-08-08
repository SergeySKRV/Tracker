import UIKit

// MARK: - AddTrackerViewModelProtocol
protocol AddTrackerViewModelProtocol: TrackerFormViewModelProtocol {
    func saveTracker(
        title: String,
        emoji: String,
        color: UIColor,
        schedule: Set<Weekday>,
        categoryId: UUID,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

// MARK: - AddTrackerViewModel
final class AddTrackerViewModel: AddTrackerViewModelProtocol {
    
    // MARK: - Properties
    var trackerTitle: String = ""
    var selectedEmoji: String?
    var selectedColor: UIColor?
    var selectedDays: Set<Weekday> = []
    var selectedCategoryId: UUID?
    var options: [String]
    var selectedCategoryTitle: String?
    
    private let type: TrackerType
    private let dataProvider: TrackerDataProviderProtocol
    
    // MARK: - Lifecycle
    init(type: TrackerType, dataProvider: TrackerDataProviderProtocol = TrackerDataProvider.shared) {
        self.type = type
        self.dataProvider = dataProvider
        self.options = type == .habit ? [NSLocalizedString("Категория", comment: ""), NSLocalizedString("Расписание", comment: "")] : [NSLocalizedString("Категория", comment: "")]
    }
    
    // MARK: - Public Methods
    func updateSaveButtonState() -> Bool {
        let isValid = !trackerTitle.isEmpty &&
                      selectedEmoji != nil &&
                      selectedColor != nil &&
                      selectedCategoryId != nil
        
        if type == .habit {
            return isValid && !selectedDays.isEmpty
        }
        return isValid
    }
    
    func saveTracker(
        title: String,
        emoji: String,
        color: UIColor,
        schedule: Set<Weekday>,
        categoryId: UUID,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let tracker = Tracker(
            id: UUID(),
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule,
            isPinned: false,
            categoryId: categoryId
        )
        
        do {
            try dataProvider.addTracker(tracker, categoryId: categoryId)
            NotificationCenter.default.post(name: NSNotification.Name("TrackerDataChanged"), object: nil)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
