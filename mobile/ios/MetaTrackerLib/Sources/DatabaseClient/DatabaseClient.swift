import ComposableArchitecture
import Foundation
import Models

public struct DatabaseClient {

  public var saveTrackings: ([Tracking]) -> Effect<Void, Error>
  public var fetchTrackingHistory: () -> Effect<[TrackingHistory.Entry], Error>

  public init(
    saveTrackings: @escaping ([Tracking]) -> Effect<Void, Error>,
    fetchTrackingHistory: @escaping () -> Effect<[TrackingHistory.Entry], Error>
  ) {
    self.saveTrackings = saveTrackings
    self.fetchTrackingHistory = fetchTrackingHistory
  }
}

#if DEBUG
  import XCTestDynamicOverlay

  extension DatabaseClient {
    public static let failing = DatabaseClient(
      saveTrackings: { _ in
        .failing("DatabaseClient.saveTrackings()")
      },
      fetchTrackingHistory: { .failing("DatabaseClient.fetchTrackingHistory()") }
    )

    public static let noop = DatabaseClient(
      saveTrackings: { _ in .none },
      fetchTrackingHistory: { .none }
    )
  }
#endif
