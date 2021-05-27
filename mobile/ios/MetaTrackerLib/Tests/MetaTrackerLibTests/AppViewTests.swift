import AnalyticsClient
import ComposableArchitecture
import Foundation
import MetaTrackerLib
import Models
import XCTest

@testable import APIClient

final class AppViewTests: XCTestCase {
  func test_appView_searchTextChanged_changesSeachText() {
    let store = TestStore(
      initialState: .init(),
      reducer: appReducer,
      environment: .failing
    )

    store.assert(
      .send(.searchTextChanged("LE258050301SE")) {
        $0.searchText = "LE258050301SE"
      }
    )
  }

  func test_appView_searchCanceled_shouldClearSearchText() {
    let store = TestStore(
      initialState: .init(searchText: "LE258050301SE", isSearchInFlight: true),
      reducer: appReducer,
      environment: .failing
    )

    store.assert(
      .send(.searchCanceled) {
        $0.isSearchInFlight = false
      },
      .receive(.searchTextChanged("")) {
        $0.searchText = ""
      }
    )
  }

  func test_AppView_SuccessSearchResults_ShouldSetItemsAndSetFalseToSearchInFlight() {
    let store = TestStore(
      initialState: .init(isSearchInFlight: true),
      reducer: appReducer,
      environment: .failing
    )

    let event = Tracking.Event.stub()

    store.assert(
      .send(.searchResults(.success([event]))) {
        $0.isSearchInFlight = false
        $0.items = [event]
      }
    )
  }

  func test_AppView_FailureSearchResults_ShouldSetFalseToSearchInFlight() {
    let store = TestStore(
      initialState: .init(isSearchInFlight: true),
      reducer: appReducer,
      environment: .failing
    )

    struct DummyError: Error {}
    store.assert(
      .send(.searchResults(.failure(DummyError() as NSError))) {
        $0.isSearchInFlight = false
      }
    )
  }

  func test_AppView_SearchCommited_ShouldPerformRequest() {
    let response = TrackingResponse.stub()
    let events = (response.events ?? [])
      .map(Tracking.Event.init(from:))
      .sorted { $0.trackedAt > $1.trackedAt }

    let scheduler = DispatchQueue.test
    var env = AppEnvironment.failing

    env.api.trackings = { _ in .init(value: [Tracking(from: response)]) }
    env.mainQueue = scheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: .init(searchText: "LE251026577SE"),
      reducer: appReducer,
      environment: env
    )

    store.assert(
      .send(.searchCommited) {
        $0.isSearchInFlight = true
      },
      .do { scheduler.advance() },
      .receive(.searchResults(.success(events))) {
        $0.isSearchInFlight = false
        $0.items = events
      }
    )
  }

  func test_AppView_SearechCommited_ShouldPerformRequestAndReturnError() {
    struct DummyError: Swift.Error {}

    let scheduler = DispatchQueue.test
    var env = AppEnvironment.failing
    env.api.trackings = { _ in Effect(error: DummyError()) }
    env.mainQueue = scheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: .init(searchText: "LE251026577SE"),
      reducer: appReducer,
      environment: env
    )

    store.assert(
      .send(.searchCommited) {
        $0.isSearchInFlight = true
      },
      .do { scheduler.advance() },
      .receive(.searchResults(.failure(DummyError() as NSError))) {
        $0.isSearchInFlight = false
        $0.items = []
      }
    )
  }

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

extension TrackingResponse {
  static func stub() -> TrackingResponse {
    TrackingResponse(
      code: "LE251026577SE",
      events: [
        TrackingResponse.Event(
          description: "Objeto postado",
          trackedAt: Date(timeIntervalSince1970: 0)
        ),
        TrackingResponse.Event(
          description: "Objeto recebido na unidade de exportação no país de origem",
          trackedAt: Date(timeIntervalSince1970: 3600)
        ),
      ]
    )
  }
}
extension Tracking.Event {

  static func stub() -> Tracking.Event {
    Tracking.Event(
      description: "",
      trackedAt: Date()
    )
  }
}
