import Foundation

public struct AnalyticsClient {
  public var initialize: () -> Void
  public var track: (Event) -> Void

  public init(
    initialize: @escaping () -> Void,
    track: @escaping (Event) -> Void
  ) {
    self.initialize = initialize
    self.track = track
  }
}

#if DEBUG
  import XCTestDynamicOverlay

  extension AnalyticsClient {

    public static var failing = AnalyticsClient(
      initialize: { XCTFail("AnalyticsClient.initialize is unimplemented") },
      track: { XCTFail("AnalyticsClient.track(\($0)) is unimplemented.") }
    )
  }

#endif
