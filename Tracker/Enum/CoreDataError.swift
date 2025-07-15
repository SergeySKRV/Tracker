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
        case .categoryNotFound: "Категория не найдена"
        case .trackerNotFound: "Трекер не найден"
        case .saveError(let error): "Ошибка сохранения: \(error.localizedDescription)"
        case .fetchError(let error): "Ошибка загрузки данных: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Helper Methods
    func log() {
        print("CoreData Error: \(errorDescription ?? "Неизвестная ошибка")")
    }
}
