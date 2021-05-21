import ComposableArchitecture
import Foundation
import MetaTrackerLib
import Models
import XCTest

@testable import APIClient

extension AppEnvironment {
  static let failing = Self(
    api: .init(trackings: { codes in
      XCTFail("APIClient.trackings(\(codes)) is unimplemented.")
      return .none
    }),
    db: .init(),
    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
  )
}

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
      initialState: .init(searchText: "LE258050301SE"),
      reducer: appReducer,
      environment: .failing
    )

    store.assert(
      .send(.searchCanceled),
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

  // TODO: Test `searchCommited` action.
}

extension Tracking.Event {

  static func stub() -> Tracking.Event {
    Tracking.Event(
      description: "",
      trackedAt: Date()
    )
  }
}
