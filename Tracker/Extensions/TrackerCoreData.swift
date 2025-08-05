import UIKit
import CoreData

// MARK: - TrackerCoreData + Conversion
extension TrackerCoreData {
    
    // MARK: - Conversion Methods
    func toTracker() -> Tracker? {
        guard let id = id,
              let title = title,
              let emoji = emoji,
              let colorHex = color,
              let color = UIColor(hex: colorHex),
              let category = category,
              let categoryId = category.id
        else {
            print("Failed to convert TrackerCoreData: Missing required fields")
            return nil
        }
        
        let schedule: Set<Weekday> = decodeSchedule(from: schedule)
        
        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule,
            isPinned: isPinned,
            categoryId: categoryId
        )
    }
    
    private func decodeSchedule(from data: Data?) -> Set<Weekday> {
        guard let data = data else { return [] }
        do {
            let weekdays = try JSONDecoder().decode([Weekday].self, from: data)
            return Set(weekdays)
        } catch {
            print("Failed to decode schedule: \(error)")
            return []
        }
    }
}

// MARK: - TrackerRecordCoreData + Conversion
extension TrackerRecordCoreData {
    
    // MARK: - Conversion Methods
    func toTrackerRecord() -> TrackerRecord? {
        guard let trackerID = trackerID, let date = date else {
            print("Failed to convert TrackerRecordCoreData: Missing required fields")
            return nil
        }
        return TrackerRecord(trackerID: trackerID, date: date)
    }
}
