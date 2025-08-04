import Foundation

// MARK: - CategoryError
enum CategoryError: Error {
    case duplicateName
    case notFound
    case coreDataError(Error)
}

// MARK: - CategoryError + LocalizedError
extension CategoryError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .duplicateName:
            return "Категория с таким названием уже существует"
        case .notFound:
            return "Категория не найдена"
        case .coreDataError(let error):
            return "Ошибка CoreData: \(error.localizedDescription)"
        }
    }
}
