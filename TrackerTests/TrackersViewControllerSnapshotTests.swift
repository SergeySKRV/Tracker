import XCTest
import SnapshotTesting
@testable import Tracker

class TrackersViewControllerSnapshotTests: XCTestCase {
    
    func testTrackersViewControllerLightMode() {
        let mockVM = MockTrackersViewModel()
        let vc = TrackersViewController(viewModel: mockVM)
      
        setupMockData(for: mockVM)
   
        vc.overrideUserInterfaceStyle = .light
     
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)), named: "light_mode")
    }
    
    func testTrackersViewControllerDarkMode() {
        let mockVM = MockTrackersViewModel()
        let vc = TrackersViewController(viewModel: mockVM)
       
        setupMockData(for: mockVM)
        
        vc.overrideUserInterfaceStyle = .dark
        
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)), named: "dark_mode")
    }
    
    private func setupMockData(for mockVM: MockTrackersViewModel) {
        guard let categoryId1 = UUID(uuidString: "00000000-0000-0000-0000-000000000001"),
              let categoryId2 = UUID(uuidString: "00000000-0000-0000-0000-000000000002") else {
            XCTFail("Failed to create UUIDs from strings")
            return
        }
        
        mockVM.stubVisibleCategories = [
            TrackerCategory(
                id: categoryId1,
                title: "Здоровье",
                trackers: [
                    Tracker(
                        id: UUID(),
                        title: "Пить воду",
                        color: UIColor(red: 0.31, green: 0.53, blue: 0.78, alpha: 1.0),
                        emoji: "💧",
                        schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday],
                        isPinned: false,
                        categoryId: UUID()
                    ),
                    Tracker(
                        id: UUID(),
                        title: "Утренняя зарядка",
                        color: UIColor(red: 1.0, green: 0.42, blue: 0.21, alpha: 1.0),
                        emoji: "💪",
                        schedule: [.monday, .wednesday, .friday],
                        isPinned: true,
                        categoryId: UUID()
                    )
                ]
            ),
            TrackerCategory(
                id: categoryId2,
                title: "Работа",
                trackers: [
                    Tracker(
                        id: UUID(),
                        title: "Проверить почту",
                        color: UIColor(red: 0.44, green: 0.63, blue: 0.32, alpha: 1.0),
                        emoji: "✉️",
                        schedule: [.monday, .tuesday, .wednesday, .thursday, .friday],
                        isPinned: false,
                        categoryId: UUID()
                    )
                ]
            )
        ]
    }
}

class MockTrackersViewModel: TrackersViewModelProtocol {
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
