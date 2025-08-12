import AppMetricaCore
import Foundation

// MARK: - Analytics Service
final class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    func reportEvent(_ event: AnalyticsEvent) {
        var parameters: [String: Any] = [
            "event": event.type.rawValue,
            "screen": event.screen.rawValue
        ]
        
        if let item = event.item?.rawValue {
            parameters["item"] = item
        }
        
        if let additionalParameters = event.additionalParameters {
            parameters.merge(additionalParameters) { (_, new) in new }
        }
        
        AppMetrica.reportEvent(name: "user_action", parameters: parameters)
        print("Analytics Event: \(parameters)")
    }
}

// MARK: - Models

// MARK: - Analytics Event Type
enum AnalyticsEventType: String {
    case open, close, click
}

// MARK: - Analytics Screen
enum AnalyticsScreen: String {
    // MARK: - Main Screens
    case main = "Main"
    case statistics = "Statistics"
    case tabBar = "TabBar"
    
    // MARK: - Creation/Edit Screens
    case createCategory = "CreateCategory"
    case editCategory = "EditCategory"
    case createTracker = "CreateTracker"
    case editTracker = "EditTracker"
    case trackerType = "TrackerType"
    
    // MARK: - Navigation/Utility Screens
    case filter = "Filter"
    case schedule = "Schedule"
    case categories = "Categories"
    case onboarding = "Onboarding"
}

// MARK: - Analytics Item
enum AnalyticsItem: String {
    // MARK: - Main Screen Items
    case addTrack = "add_track" // Кнопка "+" на главном экране
    case filter = "filter" // Кнопка "Фильтры" на главном экране
    case track = "track" // Нажатие на трекер (ячейку) или кнопку выполнения в ячейке
    case edit = "edit" // Пункт "Редактировать" в контекстном меню
    case delete = "delete" // Пункт "Удалить" в контекстном меню
    case pin = "pin" // Пункт "Закрепить" в контекстном меню
    case unpin = "unpin" // Пункт "Открепить" в контекстном меню
    
    // MARK: - Statistics Screen Items
    // (No specific items needed for statistics screen)
    
    // MARK: - Tab Bar Items
    case trackersTab = "trackers" // Выбрана вкладка "Трекеры"
    case statisticsTab = "statistics" // Выбрана вкладка "Статистика"
    
    // MARK: - Filter Screen Items
    case applyFilter = "apply_filter" // Применение фильтра в FilterViewController
    
    // MARK: - Schedule Screen Items
    case daySelected = "day_selected" // Выбор дня в таблице
    case switchChanged = "switch_changed" // Изменение переключателя
    
    // MARK: - Onboarding Screen Items
    case done = "done" // Кнопка "Готово" в OnboardingViewController
    case pagePrevious = "page_previous" // Переход к предыдущей странице в Onboarding
    case pageNext = "page_next" // Переход к следующей странице в Onboarding
    case pageChanged = "page_changed" // Страница изменена (пролистывание) в Onboarding
    
    // MARK: - Categories Screen Items
    case addCategory = "add_category" // Кнопка "Добавить категорию"
    case deleteCategory = "delete_category" // Удаление категории в CategoriesViewController
    case deleteCancel = "delete_cancel" // Отмена удаления категории
    case selectCategory = "select_category" // Выбор категории
    case categoryCreated = "category_created" // Создание категории
    case categoryUpdated = "category_updated" // Обновление категории
    case editCategory = "edit_category" // Редактирование категории
    
    // MARK: - Create Category Screen Items
    case textChanged = "text_changed" // Изменение текста в поле ввода
    case returnKey = "return_key" // Нажатие клавиши Return
    case createCategory = "create_category" // Создание категории
    
    // MARK: - Edit Category Screen Items
    case duplicateCategory = "duplicate_category" // Попытка создания дубликата категории
    case saveCategory = "save_category" // Сохранение категории
    
    // MARK: - Create/Edit Tracker Screen Items
    case createHabit = "create_habit" // Кнопка "Привычка" в TrackerTypeViewController
    case createEvent = "create_event" // Кнопка "Событие" в TrackerTypeViewController
    case cancel = "cancel" // Кнопка "Отменить" (общая)
    case save = "save" // Кнопка "Сохранить" (общая)
    case saveSuccess = "save_success" // Успешное сохранение
    case cancelEdit = "cancel_edit" // Отмена редактирования
    case saveTracker = "save_tracker" // Сохранение трекера
    case titleTextChanged = "title_text_changed" // Изменение текста в поле названия
    case validationError = "validation_error" // Ошибка валидации
    case saveButton = "save_button" // Нажатие кнопки сохранения
    case cancelButton = "cancel_button" // Нажатие кнопки отмены
    case selectEmoji = "select_emoji" // Выбор эмодзи
    case selectColor = "select_color" // Выбор цвета
    case categorySelected = "category_selected" // Выбор категории в форме
    case scheduleSelected = "schedule_selected" // Выбор расписания в форме
}

// MARK: - Analytics Event
struct AnalyticsEvent {
    let type: AnalyticsEventType
    let screen: AnalyticsScreen
    let item: AnalyticsItem?
    let additionalParameters: [String: Any]?
    
    // MARK: - Initializers
    init(type: AnalyticsEventType, screen: AnalyticsScreen, item: AnalyticsItem? = nil) {
        self.type = type
        self.screen = screen
        self.item = item
        self.additionalParameters = nil
    }
    
    init(type: AnalyticsEventType, screen: AnalyticsScreen, item: AnalyticsItem? = nil, additionalParameters: [String: Any]? = nil) {
        self.type = type
        self.screen = screen
        self.item = item
        self.additionalParameters = additionalParameters
    }
}
