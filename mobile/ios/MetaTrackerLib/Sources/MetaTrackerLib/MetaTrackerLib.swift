import APIClient
import AnalyticsClient
import ComposableArchitecture
import DatabaseClient
import Models
import OSLog
import SwiftUI

public struct AppState: Equatable {

  public var searchState: SearchState

  public init(searchState: SearchState = .init()) {
    self.searchState = searchState
  }
}

public enum AppAction: Equatable {
  case appDelegate(AppDelegateAction)
  case searchAction(SearchAction)

}

public enum AppDelegateAction: Equatable {
  case didFinishLaunching
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, env in
  switch action {
  case .appDelegate(.didFinishLaunching):
    return .concatenate(
      .fireAndForget { env.analytics.initialize() },
      .fireAndForget { env.analytics.track(.appLaunched) }
    )

  case .searchAction:
    return .none
  }
}
.combined(
  with: searchReducer.pullback(
    state: \.searchState,
    action: /AppAction.searchAction,
    environment: \.searchEnvironment
  )
)

extension Result: Identifiable where Success == Tracking, Failure == TrackingError {
  public var id: String {
    switch self {
    case .success(let tracking):
      return "Tracking(\(tracking.id))"
    case .failure(let error):
      return "Error(\(error.code))"
    }
  }
}

extension Result where Success == Tracking, Failure == TrackingError {
  var code: String {
    switch self {
    case .success(let tracking):
      return tracking.code
    case .failure(let error):
      return error.code
    }
  }
}

public struct AppView: View {
  let store: Store<AppState, AppAction>

  public init(store: Store<AppState, AppAction>) {
    self.store = store
  }

  public var body: some View {
    SearchView(
      store: store.scope(
        state: \.searchState,
        action: AppAction.searchAction
      )
    )
  }
}
