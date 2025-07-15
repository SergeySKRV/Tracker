import UIKit

// MARK: - Tracker Constants
enum TrackerConstants {
    static let maxTitleLength = 38
    
    static let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
                        "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    static let colors: [UIColor] = [
        .colorSelection01, .colorSelection02, .colorSelection03, .colorSelection04, .colorSelection05,
        .colorSelection06, .colorSelection07, .colorSelection08, .colorSelection09, .colorSelection10,
        .colorSelection11, .colorSelection12, .colorSelection13, .colorSelection14, .colorSelection15,
        .colorSelection16, .colorSelection17, .colorSelection18
    ]
    
    static let cellSize: CGFloat = 52
    static let columnsCount: Int = 6
    static let rowsCount: Int = 3
    
    struct Layout {
        static let cornerRadius: CGFloat = 16
        static let textFieldHeight: CGFloat = 75
        static let buttonHeight: CGFloat = 60
        static let collectionHeight: CGFloat = 204
        static let defaultSpacing: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let smallSpacing: CGFloat = 8
    }
    
    struct Text {
        static let newHabitTitle = "Новая привычка"
        static let newEventTitle = "Новое нерегулярное событие"
        static let trackerNamePlaceholder = "Введите название трекера"
        static let categoryOption = "Категория"
        static let scheduleOption = "Расписание"
        static let emojiTitle = "Emoji"
        static let colorTitle = "Цвет"
        static let cancelButton = "Отменить"
        static let createButton = "Создать"
        static let lengthError = "Ограничение 38 символов"
    }
}

// MARK: - TrackerType Enum
enum TrackerType {
    case habit
    case event
}

