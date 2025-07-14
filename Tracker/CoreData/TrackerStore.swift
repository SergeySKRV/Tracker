import CoreData
import UIKit

// MARK: - TrackerStoreDelegate Protocol
protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers(_ updates: [IndexPath]?)
}

// MARK: - TrackerStore
final class TrackerStore: NSObject {
    
    // MARK: Properties
    private let context: NSManagedObjectContext
    private let categoryStore: TrackerCategoryStore
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    weak var delegate: TrackerStoreDelegate?
    
    // MARK: Initialization
    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext, categoryStore: TrackerCategoryStore = TrackerCategoryStore()) {
        self.context = context
        self.categoryStore = categoryStore
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: Private Methods
    private func setupFetchedResultsController() {
        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)
        ]
        request.predicate = NSPredicate(format: "category != nil")
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    private func trackerFromCoreData(_ coreData: TrackerCoreData) -> Tracker? {
        guard let id = coreData.id,
              let title = coreData.title,
              let emoji = coreData.emoji,
              let colorHex = coreData.color,
              let color = UIColor.fromHex(colorHex) else {
            return nil
        }
        
        let schedule: Set<Weekday> = {
            guard let data = coreData.schedule else { return [] }
            return (try? JSONDecoder().decode([Weekday].self, from: data)).map { Set($0) } ?? []
        }()
        
        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule,
            isPinned: coreData.isPinned
        )
    }
    
    // MARK: Public Methods
    func addTracker(_ tracker: Tracker, to categoryId: UUID? = nil) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.toHex()
        trackerCoreData.schedule = try? JSONEncoder().encode(Array(tracker.schedule))
        trackerCoreData.isPinned = tracker.isPinned
        
        let category: TrackerCategoryCoreData
        if let categoryId = categoryId {
            let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", categoryId as CVarArg)
            guard let existingCategory = try context.fetch(request).first else {
                throw CoreDataError.categoryNotFound
            }
            category = existingCategory
        } else {
            category = try categoryStore.getDefaultCategory()
        }
        
        category.addToTrackers(trackerCoreData)
        try context.save()
    }
    
    func fetchTrackers() -> [Tracker] {
        guard let sections = fetchedResultsController?.sections else { return [] }
        return sections.flatMap { section in
            section.objects?.compactMap { object in
                guard let trackerCoreData = object as? TrackerCoreData else { return nil }
                return trackerFromCoreData(trackerCoreData)
            } ?? []
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                   didChange anObject: Any,
                   at indexPath: IndexPath?,
                   for type: NSFetchedResultsChangeType,
                   newIndexPath: IndexPath?) {
        var updates: [IndexPath] = []
        
        switch type {
        case .insert: if let newIndexPath = newIndexPath { updates.append(newIndexPath) }
        case .delete: if let indexPath = indexPath { updates.append(indexPath) }
        case .update: if let indexPath = indexPath { updates.append(indexPath) }
        case .move:
            if let indexPath = indexPath { updates.append(indexPath) }
            if let newIndexPath = newIndexPath { updates.append(newIndexPath) }
        @unknown default: break
        }
        
        delegate?.didUpdateTrackers(updates.isEmpty ? nil : updates)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers(nil)
    }
}
