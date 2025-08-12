import Foundation
@testable import Tracker

final class TrackersViewModelMock: TrackersViewModelProtocol {
    var currentDate = Date()
    var searchText = ""
    var currentFilter: TrackersViewModel.FilterType = .all
    var stubVisibleCategories: [TrackerCategory] = []
    
    var visibleCategories: [TrackerCategory] { stubVisibleCategories }
    var hasTrackersOnSelectedDate: Bool { !stubVisibleCategories.isEmpty }
    var isFilterActive: Bool { false }
    
    var onFilterChanged: (() -> Void)?
    var onDataUpdate: (() -> Void)?
    
    func loadData() {}
    func updateVisibleCategories() { onDataUpdate?() }
    func isTrackerCompleted(_ trackerID: UUID, for date: Date) -> Bool { false }
    func getTotalCompletionCount(for trackerID: UUID) -> Int { 0 }
    func getCategoryTitle(for categoryId: UUID) -> String? { nil }
    func toggleTrackerCompletion(_ tracker: Tracker, for date: Date) {}
    func updateSearchText(_ text: String) {}
    func updateCurrentDate(_ date: Date) {}
    func togglePinStatus(for tracker: Tracker) {}
    func deleteTracker(_ tracker: Tracker, completion: @escaping (Result<Void, Error>) -> Void) {}
}
