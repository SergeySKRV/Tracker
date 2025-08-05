import Foundation

// MARK: - ScheduleViewModel
final class ScheduleViewModel {
    
    // MARK: - Properties
    private let daysOfWeek = Weekday.allCases
    var selectedDays: Set<Weekday>
    
    // MARK: - Output
    var onSelectionChanged: (() -> Void)?
    
    // MARK: - Lifecycle
    init(selectedDays: Set<Weekday> = []) {
        self.selectedDays = selectedDays
    }
    
    // MARK: - Public Methods
    func numberOfDays() -> Int {
        daysOfWeek.count
    }
    
    func day(at index: Int) -> Weekday? {
        guard index >= 0, index < daysOfWeek.count else { return nil }
        return daysOfWeek[index]
    }
    
    func isDaySelected(at index: Int) -> Bool {
        if let day = day(at: index) {
            return selectedDays.contains(day)
        }
        return false
    }
    
    func toggleDay(at index: Int) {
        if let day = day(at: index) {
            if selectedDays.contains(day) {
                selectedDays.remove(day)
            } else {
                selectedDays.insert(day)
            }
            onSelectionChanged?()
        }
    }
    
    func isSelectedDay(_ day: Weekday) -> Bool {
        selectedDays.contains(day)
    }
    
    func selectedDaysSorted() -> [Weekday] {
        Array(selectedDays).sorted { $0.rawValue < $1.rawValue }
    }
}
