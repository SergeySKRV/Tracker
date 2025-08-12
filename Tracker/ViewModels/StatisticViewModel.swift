import Foundation

// MARK: - StatisticsViewModelProtocol
protocol StatisticsViewModelProtocol: AnyObject {
    var bestPeriod: Int { get }
    var perfectDays: Int { get }
    var trackersCompleted: Int { get }
    var averageValue: Int { get }
    var isEmpty: Bool { get }
    var onDataUpdate: (() -> Void)? { get set }
    
    func loadData()
}

// MARK: - StatisticsViewModel
final class StatisticsViewModel: StatisticsViewModelProtocol {
    
    // MARK: - Properties
    private let dataProvider: TrackerDataProviderProtocol
    
    var bestPeriod: Int = 0
    var perfectDays: Int = 0
    var trackersCompleted: Int = 0
    var averageValue: Int = 0
    
    var isEmpty: Bool {
        return bestPeriod == 0 && perfectDays == 0 && trackersCompleted == 0 && averageValue == 0
    }
    
    var onDataUpdate: (() -> Void)?
    
    // MARK: - Initialization
    init(dataProvider: TrackerDataProviderProtocol = TrackerDataProvider.shared) {
        self.dataProvider = dataProvider
    }
    
    // MARK: - Public Methods
    func loadData() {
        calculateStatistics()
        onDataUpdate?()
    }
    
    // MARK: - Private Methods
    private func calculateStatistics() {
        let allTrackers = dataProvider.getAllTrackers()
        let allRecords = dataProvider.fetchRecords()
        
        bestPeriod = calculateBestPeriod(records: allRecords)
        
        perfectDays = calculatePerfectDays(records: allRecords, trackers: allTrackers)
        
        trackersCompleted = allRecords.count
      
        averageValue = calculateAverageValue(records: allRecords)
    }
    
    private func calculateBestPeriod(records: [TrackerRecord]) -> Int {
        guard !records.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let recordsByDate = Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.date)
        }
        
        let sortedDates = recordsByDate.keys.sorted()
        var maxStreak = 0
        var currentStreak = 0
        var previousDate: Date?
        
        for date in sortedDates {
            if let prevDate = previousDate {
                let components = calendar.dateComponents([.day], from: prevDate, to: date)
                if components.day == 1 {
                    currentStreak += 1
                } else {
                    maxStreak = max(maxStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            previousDate = date
        }
        
        maxStreak = max(maxStreak, currentStreak)
        return maxStreak
    }
    
    private func calculatePerfectDays(records: [TrackerRecord], trackers: [Tracker]) -> Int {
        guard !records.isEmpty && !trackers.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let recordsByDate = Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.date)
        }
        
        let uniqueTrackersCount = Set(trackers.map { $0.id }).count
        var perfectDaysCount = 0
        
        for (_, dailyRecords) in recordsByDate {
            let uniqueTrackersInDay = Set(dailyRecords.map { $0.trackerID }).count
            if uniqueTrackersInDay >= uniqueTrackersCount {
                perfectDaysCount += 1
            }
        }
        
        return perfectDaysCount
    }
    
    private func calculateAverageValue(records: [TrackerRecord]) -> Int {
        guard !records.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let recordsByDate = Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.date)
        }
        
        let totalRecords = records.count
        let totalDays = recordsByDate.count
        
        guard totalDays > 0 else { return 0 }
        
        let average = Double(totalRecords) / Double(totalDays)
        return Int(round(average))
    }
}
