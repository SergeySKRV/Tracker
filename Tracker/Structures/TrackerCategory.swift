import Foundation

// MARK: - TrackerCategory Model
struct TrackerCategory {
    
    // MARK: Properties
    let id: UUID
    let title: String
    let trackers: [Tracker]

    // MARK: Initialization
    init(title: String, trackers: [Tracker]) {
        self.id = UUID()
        self.title = title
        self.trackers = trackers
    }
}
