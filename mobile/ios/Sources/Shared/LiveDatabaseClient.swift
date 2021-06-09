import CoreData
import DatabaseClient
import ComposableArchitecture
import Models

extension DatabaseClient {
    static let live = { () -> DatabaseClient in
        let live = LiveDatabaseClient()
        return DatabaseClient(
            saveTrackings: { trackings in
                .catching { try live.saveTrackings(trackings) }
            }
        )
    }()
}

struct LiveDatabaseClient {
    let container: NSPersistentCloudKitContainer
    
    var moc: NSManagedObjectContext { container.viewContext }
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "MetaTracker")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    func saveTrackings(_ trackings: [Tracking]) throws {
        guard trackings.isEmpty == false else { return }
        try removeTrackings(withCodes: trackings.map(\.code))
        
        trackings.forEach {
            let tracking = CDTracking(context: moc)
            tracking.code = $0.code
            tracking.isDelivered = $0.isDelivered
            tracking.lastSavedAt = Date()
        }
        
        try moc.save()
    }
    
    private func removeTrackings(withCodes codes: [String]) throws {
        let request = CDTracking.makeFetchRequest()
        request.predicate = NSPredicate(format: "%K in %@", #keyPath(CDTracking.code), codes)
        try moc.fetch(request).forEach {
            moc.delete($0)
        }
    }
}
