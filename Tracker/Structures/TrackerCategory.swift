import Foundation

// MARK: - TrackerCategory
struct TrackerCategory: Equatable {
    let id: UUID
    let title: String
    let trackers: [Tracker]
    
    init(id: UUID = UUID(), title: String, trackers: [Tracker] = []) {
        self.id = id
        self.title = title
        self.trackers = trackers
    }
    
    static func == (lhs: TrackerCategory, rhs: TrackerCategory) -> Bool {
        return lhs.id == rhs.id
    }
}
