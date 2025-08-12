import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {
    private var vm: TrackersViewModelMock!
    private var sut: TrackersViewController!

    override func setUp() {
        super.setUp()
        vm = .snapshotFixture()
        sut = TrackersViewController(viewModel: vm)
    }

    override func tearDown() {
        sut = nil
        vm = nil
        super.tearDown()
    }

    func testTrackersViewControllerLightMode() {
        // When
        sut.overrideUserInterfaceStyle = .light
        // Then
        assertSnapshot(of: sut, as: .image(traits: .init(userInterfaceStyle: .light)), named: "light_mode")
    }

    func testTrackersViewControllerDarkMode() {
        // When
        sut.overrideUserInterfaceStyle = .dark
        // Then
        assertSnapshot(of: sut, as: .image(traits: .init(userInterfaceStyle: .dark)), named: "dark_mode")
    }
}
