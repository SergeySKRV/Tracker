import Foundation

// MARK: - CategoriesViewModel
final class CategoriesViewModel {
    
    // MARK: - Properties
    var didUpdateCategories: (() -> Void)?
    
    private let categoryStore: TrackerCategoryStore
    private var categories: [TrackerCategory] = []
    private var selectedCategory: TrackerCategory?
    
    // MARK: - Lifecycle
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore()) {
        self.categoryStore = categoryStore
        loadCategories()
    }
    
    // MARK: - Public Methods
    func loadCategories() {
        categories = categoryStore.fetchAllCategories()
        didUpdateCategories?()
    }
    
    func numberOfCategories() -> Int {
        categories.count
    }
    
    func categoryTitle(at index: Int) -> String {
        guard index >= 0 && index < categories.count else { return "" }
        return categories[index].title
    }
    
    func category(at index: Int) -> TrackerCategory {
        guard index >= 0 && index < categories.count else {
            fatalError("Index out of range")
        }
        return categories[index]
    }
    
    func isCategorySelected(at index: Int) -> Bool {
        guard index >= 0 && index < categories.count else { return false }
        return categories[index] == selectedCategory
    }
    
    func selectCategory(_ category: TrackerCategory) {
        selectedCategory = category
    }
    
    func selectCategory(by id: UUID) {
        if let category = categories.first(where: { $0.id == id }) {
            selectedCategory = category
        }
    }
    
    func getSelectedCategory() -> TrackerCategory? {
        selectedCategory
    }
    
    func getSelectedCategoryTitle() -> String {
        return selectedCategory?.title ?? "Не выбрана"
    }
    
    func addCategory(title: String) {
        if categories.contains(where: { $0.title.lowercased() == title.lowercased() }) {
            print("Категория с таким названием уже существует")
            return
        }
        
        do {
            try categoryStore.addCategory(title: title)
            loadCategories()
        } catch {
            print("Error adding category: \(error)")
        }
    }
    
    func updateCategory(_ category: TrackerCategory, with newTitle: String) throws {
        if hasCategory(with: newTitle, excludingId: category.id) {
            throw CategoryError.duplicateName
        }
        
        do {
            try categoryStore.updateCategory(category, with: newTitle)
            
            if let index = categories.firstIndex(where: { $0.id == category.id }) {
                categories[index] = TrackerCategory(
                    id: category.id,
                    title: newTitle,
                    trackers: category.trackers
                )
            }
            
            didUpdateCategories?()
            
            NotificationCenter.default.post(
                name: NSNotification.Name("CategoryTitleDidUpdate"),
                object: nil,
                userInfo: ["categoryId": category.id]
            )
        } catch {
            throw CategoryError.coreDataError(error)
        }
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        try categoryStore.deleteCategory(category)
        loadCategories()
    }
    
    func getAllCategories() -> [TrackerCategory] {
        return categories
    }
    
    func hasCategory(with title: String, excludingId: UUID? = nil) -> Bool {
        return categories.contains { $0.title == title && $0.id != excludingId }
    }
}
