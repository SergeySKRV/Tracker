import UIKit

// MARK: - Tracker Type
enum TrackerType {
    case habit
    case event
}

// MARK: - Analytics Constants
enum AnalyticsConstants {
    static let appMetricaAPIKey = "147a279e-5dcc-4356-a7bb-06b778f39284"
}

// MARK: - Tracker Constants
enum TrackerConstants {
    
    // MARK: Content
    static let cellSize: CGFloat = 52
    static let interItemSpacing: CGFloat = 5
    static let columnsCount: Int = 6
    static let rowsCount: Int = 3
    
    static let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
        "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    static let colors: [UIColor] = [
        .colorSelection01, .colorSelection02, .colorSelection03, .colorSelection04, .colorSelection05,
        .colorSelection06, .colorSelection07, .colorSelection08, .colorSelection09, .colorSelection10,
        .colorSelection11, .colorSelection12, .colorSelection13, .colorSelection14, .colorSelection15,
        .colorSelection16, .colorSelection17, .colorSelection18
    ]
    
    // MARK: General
    static let maxTitleLength = 38
    
    // MARK: Text
    enum Text {
        static let newHabitTitle = NSLocalizedString("Новая привычка", comment: "")
        static let newEventTitle = NSLocalizedString("Новое нерегулярное событие", comment: "")
        static let trackerNamePlaceholder = NSLocalizedString("Введите название трекера", comment: "")
        static let categoryOption = NSLocalizedString("Категория", comment: "")
        static let scheduleOption = NSLocalizedString("Расписание", comment: "")
        static let emojiTitle = NSLocalizedString("Emoji", comment: "")
        static let colorTitle = NSLocalizedString("Цвет", comment: "")
        static let cancelButton = NSLocalizedString("Отменить", comment: "")
        static let createButton = NSLocalizedString("Создать", comment: "")
        static let saveButton = NSLocalizedString("Сохранить", comment: "")
        static let lengthError = NSLocalizedString("Ограничение 38 символов", comment: "")
    }
    
    // MARK: Layout
    enum Layout {
        static let cornerRadius: CGFloat = 16
        static let textFieldHeight: CGFloat = 75
        static let buttonHeight: CGFloat = 60
        static let collectionHeight: CGFloat = 204
        static let defaultSpacing: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let smallSpacing: CGFloat = 8
    }
}
