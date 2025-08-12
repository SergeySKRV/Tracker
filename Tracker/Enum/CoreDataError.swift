import Foundation

// MARK: - CoreDataError
enum CoreDataError: Error {
    
    // MARK: Cases
    case categoryNotFound
    case categoryNotSpecified
    case trackerNotFound
    case saveError(Error)
    case fetchError(Error)
}

// MARK: - CoreDataError + LocalizedError
extension CoreDataError: LocalizedError {
    
    // MARK: Properties
    var errorDescription: String? {
        switch self {
        case .categoryNotFound:
            return "Категория не найдена"
        case .trackerNotFound:
            return "Трекер не найден"
        case .categoryNotSpecified:
            return "Категория не указана"
        case .saveError(let error):
            return "Ошибка сохранения: \(error.localizedDescription)"
        case .fetchError(let error):
            return "Ошибка загрузки данных: \(error.localizedDescription)"
        }
    }
    
    // MARK: Public Methods
    func log() {
        print("CoreData Error: \(errorDescription ?? "Неизвестная ошибка")")
    }
}
