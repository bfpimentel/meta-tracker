import APIClient
import AnalyticsClient
import AppEnvironment
import ComposableArchitecture
import DatabaseClient
import Models
import OSLog
import SearchFeature
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
