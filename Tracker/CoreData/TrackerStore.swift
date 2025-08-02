import CoreData
import UIKit

// MARK: - TrackerStoreDelegate Protocol
protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers()
}

// MARK: - TrackerStore
final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private let categoryStore: TrackerCategoryStore
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    weak var delegate: TrackerStoreDelegate?

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext, categoryStore: TrackerCategoryStore = TrackerCategoryStore()) {
        self.context = context
        self.categoryStore = categoryStore
        super.init()
        setupFetchedResultsController()
    }

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
              let color = UIColor.fromHex(colorHex),
              let category = coreData.category,
              let categoryId = category.id
        else {
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
            isPinned: coreData.isPinned,
            categoryId: categoryId
        )
    }

    func addTracker(_ tracker: Tracker, to categoryId: UUID) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.toHex()
        trackerCoreData.isPinned = tracker.isPinned

        if !tracker.schedule.isEmpty {
            do {
                trackerCoreData.schedule = try JSONEncoder().encode(Array(tracker.schedule))
            } catch {
                print("Ошибка кодирования расписания: \(error)")
            }
        }

        do {
            let categoryCoreData = try categoryStore.getCategoryCoreData(by: categoryId)
            categoryCoreData.addToTrackers(trackerCoreData)
            try context.save()
           
            NotificationCenter.default.post(name: NSNotification.Name("TrackersUpdated"), object: nil)
        } catch {
            context.delete(trackerCoreData)
            throw error
        }
    }

    func deleteTracker(_ tracker: Tracker) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        guard let trackerCoreData = try context.fetch(request).first else {
            throw CoreDataError.trackerNotFound
        }
        context.delete(trackerCoreData)
        try context.save()
    }
    
    func updateTracker(_ tracker: Tracker, categoryId: UUID) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        guard let trackerCoreData = try context.fetch(request).first else {
            throw CoreDataError.trackerNotFound
        }
      
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.toHex()
        trackerCoreData.isPinned = tracker.isPinned
      
        if !tracker.schedule.isEmpty {
            do {
                trackerCoreData.schedule = try JSONEncoder().encode(Array(tracker.schedule))
            } catch {
                print("Ошибка кодирования расписания: \(error)")
            }
        } else {
            trackerCoreData.schedule = nil
        }
  
        do {
            let categoryCoreData = try categoryStore.getCategoryCoreData(by: categoryId)
            if trackerCoreData.category != categoryCoreData {
                trackerCoreData.category?.removeFromTrackers(trackerCoreData)
                categoryCoreData.addToTrackers(trackerCoreData)
            }
        } catch {
            throw error
        }
        
        try context.save()
        NotificationCenter.default.post(name: NSNotification.Name("TrackersUpdated"), object: nil)
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
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}
