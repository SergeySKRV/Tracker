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
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
    
    var fullName: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
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
