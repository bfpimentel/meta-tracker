import AnalyticsClient
import AppEnvironment
import ComposableArchitecture
import Foundation
import Models
import SearchFeature
import XCTest

@testable import APIClient

final class SearchViewTests: XCTestCase {
  func test_searchTextChanged_changesSeachText() {
    let store = TestStore(
      initialState: .init(),
      reducer: searchReducer,
      environment: AppEnvironment.failing.searchEnvironment
    )

    store.assert(
      .send(.searchTextChanged("LE258050301SE")) {
        $0.searchText = "LE258050301SE"
      }
    )
  }

  func test_searchCanceled_shouldClearSearchText() {
    let store = TestStore(
      initialState: .init(searchText: "LE258050301SE", isSearchInFlight: true),
      reducer: searchReducer,
      environment: AppEnvironment.failing.searchEnvironment
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

  func test_SuccessSearchResults_ShouldSetItemsAndSetFalseToSearchInFlight() throws {
    let store = TestStore(
      initialState: .init(isSearchInFlight: true),
      reducer: searchReducer,
      environment: AppEnvironment.failing.searchEnvironment
    )

    let tracking = Tracking.from(response: .stub())

    store.assert(
      .send(.searchResults(.success([tracking]))) {
        $0.isSearchInFlight = false
        $0.result = [tracking]
      }
    )
  }

  func test_FailureSearchResults_ShouldSetFalseToSearchInFlight() {
    let store = TestStore(
      initialState: .init(isSearchInFlight: true),
      reducer: searchReducer,
      environment: AppEnvironment.failing.searchEnvironment
    )

    struct DummyError: Error {}
    store.assert(
      .send(.searchResults(.failure(DummyError() as NSError))) {
        $0.isSearchInFlight = false
      }
    )
  }

  func test_SearchCommited_ShouldPerformRequest() {
    let response = TrackingResponse.stub()
    let tracking = Tracking.from(response: response)
    let events = (response.events ?? [])
      .map(Tracking.Event.init(from:))
      .sorted { $0.trackedAt > $1.trackedAt }

    let scheduler = DispatchQueue.test
    var env = AppEnvironment.failing.searchEnvironment

    env.api.trackings = { _ in .init(value: [tracking]) }
    env.mainQueue = scheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: .init(searchText: "LE251026577SE"),
      reducer: searchReducer,
      environment: env
    )

    store.assert(
      .send(.searchCommited) {
        $0.isSearchInFlight = true
      },
      .do { scheduler.advance() },
      .receive(.searchResults(.success([tracking]))) {
        $0.isSearchInFlight = false
        $0.result = [tracking]
      }
    )
  }

  func test_SearechCommited_ShouldPerformRequestAndReturnError() {
    struct DummyError: Swift.Error {}

    let scheduler = DispatchQueue.test
    var env = AppEnvironment.failing.searchEnvironment
    env.api.trackings = { _ in Effect(error: DummyError()) }
    env.mainQueue = scheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: .init(searchText: "LE251026577SE"),
      reducer: searchReducer,
      environment: env
    )

    store.assert(
      .send(.searchCommited) {
        $0.isSearchInFlight = true
      },
      .do { scheduler.advance() },
      .receive(.searchResults(.failure(DummyError() as NSError))) {
        $0.isSearchInFlight = false
        $0.result = []
      }
    )
  }
}

extension TrackingResponse {
  static func stub() -> TrackingResponse {
    TrackingResponse(
      code: "LE251026577SE",
      isDelivered: false,
      events: [
        TrackingResponse.Event(
          description: "Objeto postado",
          trackedAt: Date(timeIntervalSince1970: 0)
        ),
        TrackingResponse.Event(
          description: "Objeto recebido na unidade de exportação no país de origem",
          trackedAt: Date(timeIntervalSince1970: 3600)
        ),
      ],
      errorMessage: nil
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
