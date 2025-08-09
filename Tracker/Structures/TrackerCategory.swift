import Foundation

// MARK: - TrackerCategory
struct TrackerCategory: Equatable {
    
    // MARK: - Properties
    let id: UUID
    let title: String
    let trackers: [Tracker]
    
    // MARK: - Initialization
    init(id: UUID = UUID(), title: String, trackers: [Tracker] = []) {
        self.id = id
        self.title = title
        self.trackers = trackers
    }
    
    // MARK: - Equatable
    static func == (lhs: TrackerCategory, rhs: TrackerCategory) -> Bool {
        return lhs.id == rhs.id
    }
}
