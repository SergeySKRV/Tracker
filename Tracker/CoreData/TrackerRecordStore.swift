import CoreData

// MARK: - TrackerRecordStoreDelegate Protocol
protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecords(_ updates: [IndexPath]?)
}

// MARK: - TrackerRecordStore
final class TrackerRecordStore: NSObject {
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    weak var delegate: TrackerRecordStoreDelegate?
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Private Methods
    private func setupFetchedResultsController() {
        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    // MARK: - Public Methods
    func addRecord(_ record: TrackerRecord) throws {
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.id = UUID()
        recordCoreData.trackerID = record.trackerID
        recordCoreData.date = record.date
        
        try context.save()
    }
    
    func deleteRecord(for trackerId: UUID, date: Date) throws {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else { return }
        
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "trackerID == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startDate as CVarArg,
            endDate as CVarArg
        )
        
        if let record = try context.fetch(request).first {
            context.delete(record)
            try context.save()
        }
    }
    
    func fetchRecords() -> [TrackerRecord] {
        guard let records = fetchedResultsController?.fetchedObjects else { return [] }
        return records.compactMap { $0.toTrackerRecord() }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
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
        
        delegate?.didUpdateRecords(updates.isEmpty ? nil : updates)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateRecords(nil)
    }
}
