import CoreData
import UIKit

final class TrackerCategoryStore {
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    
    // MARK: - Lifecycle
    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
    }
    
    // MARK: - Public Methods
    func fetchAllCategories() -> [TrackerCategory] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        do {
            let coreDataCategories = try context.fetch(request)
            return coreDataCategories.compactMap(makeCategory)
        } catch {
            print("Ошибка загрузки категорий: \(error)")
            return []
        }
    }
    
    func getCategoryTitle(by id: UUID) -> String? {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let categories = try context.fetch(request)
            return categories.first?.title
        } catch {
            print("Ошибка получения названия категории: \(error)")
            return nil
        }
    }
    
    func addCategory(title: String) throws {
        let category = TrackerCategory(title: title)
        try addCategory(category)
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.id = category.id
        categoryCoreData.title = category.title
        try context.save()
    }
    
    func getCategoryCoreData(by id: UUID) throws -> TrackerCategoryCoreData {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let categories = try context.fetch(request)
            guard let category = categories.first else {
                throw CoreDataError.categoryNotFound
            }
            return category
        } catch {
            throw error
        }
    }
    
    func updateCategory(_ category: TrackerCategory, with newTitle: String) throws {
        let categoryCoreData = try getCategoryCoreData(by: category.id)
        categoryCoreData.title = newTitle
        try context.save()
        
        NotificationCenter.default.post(
            name: NSNotification.Name("CoreDataCategoriesDidChange"),
            object: nil
        )
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        let categoryCoreData = try getCategoryCoreData(by: category.id)
        context.delete(categoryCoreData)
        try context.save()
    }
    
    // MARK: - Private Methods
    private func makeCategory(from coreDataCategory: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let categoryId = coreDataCategory.id,
              let title = coreDataCategory.title else {
            return nil
        }

        let trackers = (coreDataCategory.trackers as? Set<TrackerCoreData>)?
            .compactMap(makeTracker(from:)) ?? []

        return TrackerCategory(id: categoryId, title: title, trackers: trackers)
    }

    private func makeTracker(from trackerData: TrackerCoreData) -> Tracker? {
        guard let id = trackerData.id,
              let title = trackerData.title,
              let emoji = trackerData.emoji,
              let colorHex = trackerData.color,
              let color = UIColor(hex: colorHex) else {
            return nil
        }

        let schedule: Set<Weekday> = {
            guard let data = trackerData.schedule else { return [] }
            do {
                let weekdays = try JSONDecoder().decode([Weekday].self, from: data)
                return Set(weekdays)
            } catch {
                print("Ошибка декодирования расписания: \(error)")
                return []
            }
        }()

        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule,
            isPinned: trackerData.isPinned,
            categoryId: trackerData.category?.id ?? UUID()
        )
    }
}
