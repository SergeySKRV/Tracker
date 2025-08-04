import Foundation

// MARK: - AddTrackerViewModel
final class AddTrackerViewModel: TrackerFormViewModel {
    // MARK: - Private Properties
    private let type: TrackerType
    private let dataProvider: TrackerDataProviderProtocol
    
    // MARK: - Lifecycle
    init(type: TrackerType, dataProvider: TrackerDataProviderProtocol = TrackerDataProvider.shared) {
        self.type = type
        self.dataProvider = dataProvider
    }
    
    // MARK: - Override Properties
    override var options: [String] {
        type == .habit ? ["Категория", "Расписание"] : ["Категория"]
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
        
        if type == .habit && selectedDays.isEmpty {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Выберите хотя бы один день для расписания"])))
            return
        }
        
        let tracker = Tracker(
            id: UUID(),
            title: trackerTitle,
            color: color,
            emoji: emoji,
            schedule: type == .habit ? selectedDays : [],
            isPinned: false,
            categoryId: categoryId
        )
        
        do {
            try dataProvider.addTracker(tracker, categoryId: categoryId)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
