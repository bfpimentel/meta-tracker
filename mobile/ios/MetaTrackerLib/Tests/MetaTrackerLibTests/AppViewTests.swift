import AnalyticsClient
import AppEnvironment
import ComposableArchitecture
import Foundation
import MetaTrackerLib
import Models
import XCTest

@testable import APIClient

final class AppViewTests: XCTestCase {
  func test_AppView_DidFinishLaunching_ShouldInitializeAnalyticsAndTrackAppLaunchedEvent() {
    var env = AppEnvironment.failing

    var analyticsInitialized = false
    env.analytics.initialize = {
      analyticsInitialized = true
    }

    var events: [Event] = []
    env.analytics.track = { events.append($0) }

    let store = TestStore(
      initialState: .init(),
      reducer: appReducer,
      environment: env
    )

    store.send(.appDelegate(.didFinishLaunching))

    XCTAssertTrue(analyticsInitialized)
    XCTAssertEqual(events, [.appLaunched])
  }
}
