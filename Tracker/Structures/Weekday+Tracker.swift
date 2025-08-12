import Foundation
import UIKit

// MARK: - Weekday
enum Weekday: Int, CaseIterable, Codable {
    
    // MARK: Cases
    case monday = 0
    case tuesday = 1
    case wednesday = 2
    case thursday = 3
    case friday = 4
    case saturday = 5
    case sunday = 6
    
    // MARK: Properties
    var shortName: String {
        switch self {
        case .monday: return NSLocalizedString("weekday_mon_short", comment: "Monday short name")
        case .tuesday: return NSLocalizedString("weekday_tue_short", comment: "Tuesday short name")
        case .wednesday: return NSLocalizedString("weekday_wed_short", comment: "Wednesday short name")
        case .thursday: return NSLocalizedString("weekday_thu_short", comment: "Thursday short name")
        case .friday: return NSLocalizedString("weekday_fri_short", comment: "Friday short name")
        case .saturday: return NSLocalizedString("weekday_sat_short", comment: "Saturday short name")
        case .sunday: return NSLocalizedString("weekday_sun_short", comment: "Sunday short name")
        }
    }
    
    var fullName: String {
        switch self {
        case .monday: return NSLocalizedString("weekday_mon_full", comment: "Monday full name")
        case .tuesday: return NSLocalizedString("weekday_tue_full", comment: "Tuesday full name")
        case .wednesday: return NSLocalizedString("weekday_wed_full", comment: "Wednesday full name")
        case .thursday: return NSLocalizedString("weekday_thu_full", comment: "Thursday full name")
        case .friday: return NSLocalizedString("weekday_fri_full", comment: "Friday full name")
        case .saturday: return NSLocalizedString("weekday_sat_full", comment: "Saturday full name")
        case .sunday: return NSLocalizedString("weekday_sun_full", comment: "Sunday full name")
        }
    }
}

// MARK: - Tracker
struct Tracker {
    
    // MARK: Properties
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: Set<Weekday>
    let isPinned: Bool
    let category: UUID?
    
    // MARK: Initialization
    init(
        id: UUID,
        title: String,
        color: UIColor,
        emoji: String,
        schedule: Set<Weekday>,
        isPinned: Bool = false,
        categoryId: UUID?
    ) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isPinned = isPinned
        self.category = categoryId
    }
}
