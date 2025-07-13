import CoreData

// MARK: - TrackerCategoryStoreDelegate Protocol
protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories(_ updates: [IndexPath]?)
}

// MARK: - TrackerCategoryStore
final class TrackerCategoryStore: NSObject {
    
    // MARK: Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    weak var delegate: TrackerCategoryStoreDelegate?
    
    // MARK: Initialization
    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: Private Methods
    private func setupFetchedResultsController() {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    // MARK: Public Methods
    func addCategory(_ category: TrackerCategory) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.id = UUID()
        categoryCoreData.title = category.title
        try context.save()
    }
    
    func fetchCategories() -> [TrackerCategory] {
        guard let categories = fetchedResultsController.fetchedObjects else { return [] }
        
        return categories.compactMap { coreData in
            guard let title = coreData.title else { return nil }
            let trackers = (coreData.trackers as? Set<TrackerCoreData>)?
                .compactMap { $0.toTracker() } ?? []
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
    
    func getDefaultCategory() throws -> TrackerCategoryCoreData {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", "Без категории")
        
        if let category = try context.fetch(request).first {
            return category
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.id = UUID()
            newCategory.title = "Без категории"
            try context.save()
            return newCategory
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories(nil)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                   didChange anObject: Any,
                   at indexPath: IndexPath?,
                   for type: NSFetchedResultsChangeType,
                   newIndexPath: IndexPath?) {
        var updates: [IndexPath] = []
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath { updates.append(newIndexPath) }
        case .delete:
            if let indexPath = indexPath { updates.append(indexPath) }
        case .update:
            if let indexPath = indexPath { updates.append(indexPath) }
        case .move:
            if let indexPath = indexPath { updates.append(indexPath) }
            if let newIndexPath = newIndexPath { updates.append(newIndexPath) }
        @unknown default:
            break
        }
        delegate?.didUpdateCategories(updates.isEmpty ? nil : updates)
    }
}
