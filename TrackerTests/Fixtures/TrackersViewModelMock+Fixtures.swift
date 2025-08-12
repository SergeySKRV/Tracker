import UIKit
@testable import Tracker

extension TrackersViewModelMock {

    @discardableResult
    func applySnapshotFixture() -> Self {
        let categoryId1 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let categoryId2 = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!

        stubVisibleCategories = [
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
                        categoryId: categoryId1
                    ),
                    Tracker(
                        id: UUID(),
                        title: "Утренняя зарядка",
                        color: UIColor(red: 1.0, green: 0.42, blue: 0.21, alpha: 1.0),
                        emoji: "💪",
                        schedule: [.monday, .wednesday, .friday],
                        isPinned: true,
                        categoryId: categoryId1
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
                        categoryId: categoryId2
                    )
                ]
            )
        ]

        return self
    }

    static func snapshotFixture() -> TrackersViewModelMock {
        TrackersViewModelMock().applySnapshotFixture()
    }
}
