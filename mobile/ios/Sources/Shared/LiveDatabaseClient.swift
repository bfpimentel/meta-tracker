import ComposableArchitecture
import CoreData
import DatabaseClient
import Models

extension DatabaseClient {
  static let live = { () -> DatabaseClient in
    let live = LiveDatabaseClient()
    return DatabaseClient(
      saveTrackings: { trackings in
        .catching { try live.saveTrackings(trackings) }
      },
      fetchTrackingHistory: {
        .catching { try live.fetchTrackingsHistory() }
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

  func fetchTrackingsHistory() throws -> [TrackingHistory.Entry] {
    let request = CDTracking.makeFetchRequest()
    request.sortDescriptors = [
      NSSortDescriptor(keyPath: \CDTracking.lastSavedAt, ascending: false)
    ]

    let trackings = try moc.fetch(request)
    return trackings.map {
      TrackingHistory.Entry(code: $0.code!, lastTrackedAt: $0.lastSavedAt!)
    }
  }

  private func removeTrackings(withCodes codes: [String]) throws {
    let request = CDTracking.makeFetchRequest()
    request.predicate = NSPredicate(format: "%K in %@", #keyPath(CDTracking.code), codes)
    try moc.fetch(request).forEach {
      moc.delete($0)
    }
  }
}
