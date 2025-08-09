import Foundation

// MARK: - Helpers
func localizedDaysCount(_ count: Int) -> String {
    let format = NSLocalizedString("days_count", comment: "Количество дней: 1 день, 2 дня, 5 дней")
    return String(format: format, count)
}
