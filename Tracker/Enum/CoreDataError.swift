import Foundation

// MARK: - CoreDataError Enum
enum CoreDataError: Error {
    case categoryNotFound
    case trackerNotFound
    case saveError(Error)
    case fetchError(Error)
}

// MARK: - LocalizedError Extension
extension CoreDataError: LocalizedError {
    
    // MARK: Computed Properties
    var errorDescription: String? {
        switch self {
        case .categoryNotFound:
            return "Категория не найдена"
        case .trackerNotFound:
            return "Трекер не найден"
        case .saveError(let error):
            return "Ошибка сохранения: \(error.localizedDescription)"
        case .fetchError(let error):
            return "Ошибка загрузки данных: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Helper Methods
    func log() {
        print("CoreData Error: \(errorDescription ?? "Неизвестная ошибка")")
    }
}
