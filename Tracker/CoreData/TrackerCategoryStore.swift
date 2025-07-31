import CoreData
import UIKit

final class TrackerCategoryStore {
    // MARK: - Properties
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
    }
    
    // MARK: - Public Methods
    func fetchAllCategories() -> [TrackerCategory] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do {
            let coreDataCategories = try context.fetch(request)
            var result: [TrackerCategory] = []
            
            for coreDataCategory in coreDataCategories {
                guard let categoryId = coreDataCategory.id,
                      let title = coreDataCategory.title else {
                    continue
                }
                
                var trackers: [Tracker] = []
                
                if let coreDataTrackers = coreDataCategory.trackers as? Set<TrackerCoreData> {
                    for trackerCoreData in coreDataTrackers {
                        guard let trackerId = trackerCoreData.id,
                              let trackerTitle = trackerCoreData.title,
                              let emoji = trackerCoreData.emoji,
                              let colorHex = trackerCoreData.color,
                              let color = UIColor(hex: colorHex) else {
                            continue
                        }
               
                        let schedule: Set<Weekday> = {
                            guard let data = trackerCoreData.schedule else { return [] }
                            do {
                                return try JSONDecoder().decode([Weekday].self, from: data).reduce(into: Set()) { $0.insert($1) }
                            } catch {
                                print("Ошибка декодирования расписания: \(error)")
                                return []
                            }
                        }()
                        
                        let tracker = Tracker(
                            id: trackerId,
                            title: trackerTitle,
                            color: color,
                            emoji: emoji,
                            schedule: schedule,
                            isPinned: trackerCoreData.isPinned,
                            categoryId: categoryId
                        )
                        
                        trackers.append(tracker)
                    }
                }
                result.append(TrackerCategory(id: categoryId, title: title, trackers: trackers))
            }
            
            return result
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
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        let categoryCoreData = try getCategoryCoreData(by: category.id)
        context.delete(categoryCoreData)
        try context.save()
    }
}
