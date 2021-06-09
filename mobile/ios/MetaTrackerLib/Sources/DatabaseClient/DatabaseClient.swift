import ComposableArchitecture
import Foundation
import Models

public struct DatabaseClient {

  public var saveTrackings: ([Tracking]) -> Effect<Void, Error>

  public init(
    saveTrackings: @escaping ([Tracking]) -> Effect<Void, Error>
  ) {
    self.saveTrackings = saveTrackings
  }
}

#if DEBUG
  import XCTestDynamicOverlay

  extension DatabaseClient {
    public static let failing = DatabaseClient(
      saveTrackings: { _ in
        XCTFail("DatabaseClient.saveTrackings() not implemented.")
        return .none
      }
    )
  }
#endif
