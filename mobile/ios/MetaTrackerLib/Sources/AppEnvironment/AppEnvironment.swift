import APIClient
import AnalyticsClient
import ComposableArchitecture
import DatabaseClient
import Foundation
import SearchFeature

public struct AppEnvironment {
  public var api: APIClient
  public var db: DatabaseClient
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var analytics: AnalyticsClient
  //  public var log: Logger

  public init(
    api: APIClient,
    db: DatabaseClient,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    analytics: AnalyticsClient
      //    log: Logger
  ) {
    self.api = api
    self.db = db
    self.mainQueue = mainQueue
    self.analytics = analytics
    //    self.log = log
  }
}

extension AppEnvironment {
  public var searchEnvironment: SearchEnvironment {
    SearchEnvironment(api: api, mainQueue: mainQueue)
  }
}

#if DEBUG
  import XCTestDynamicOverlay

  extension AppEnvironment {
    public static let failing = Self(
      api: .failing,
      db: .failing,
      mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
      analytics: .failing
    )
  }
#endif
