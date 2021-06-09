import APIClient
import AnalyticsClient
import AppEnvironment
import ComposableArchitecture
import DatabaseClient
import HistoryFeature
import Models
import OSLog
import SearchFeature
import SwiftUI

public struct AppState: Equatable {

  public var searchState: SearchState
  public var trackingHistoryState: TrackingHistoryState

  public init(
    searchState: SearchState = .init(),
    trackingHistoryState: TrackingHistoryState = .init()
  ) {
    self.searchState = searchState
    self.trackingHistoryState = trackingHistoryState
  }
}

public enum AppAction: Equatable {
  case appDelegate(AppDelegateAction)
  case searchAction(SearchAction)
  case trackingHistoryAction(TrackingHistoryAction)

}

public enum AppDelegateAction: Equatable {
  case didFinishLaunching
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  searchReducer.pullback(
    state: \.searchState,
    action: /AppAction.searchAction,
    environment: \.searchEnvironment
  ),
  trackingHistoryReducer.pullback(
    state: \.trackingHistoryState,
    action: /AppAction.trackingHistoryAction,
    environment: \.trackingHistoryEnvironment
  ),
  Reducer { state, action, env in
    switch action {
    case .appDelegate(.didFinishLaunching):
      return .concatenate(
        .fireAndForget { env.analytics.initialize() },
        .fireAndForget { env.analytics.track(.appLaunched) }
      )

    case .searchAction:
      return .none

    case .trackingHistoryAction:
      return .none
    }
  }
)

public struct AppView: View {
  let store: Store<AppState, AppAction>

  public init(store: Store<AppState, AppAction>) {
    self.store = store
  }

  public var body: some View {
    TabView {
      SearchView(
        store: store.scope(
          state: \.searchState,
          action: AppAction.searchAction
        )
      )
      .tabItem {
        Label("Buscar", systemImage: "magnifyingglass")
      }

      TrackingHistoryView(
        store: store.scope(
          state: \.trackingHistoryState,
          action: AppAction.trackingHistoryAction
        )
      )
      .tabItem {
        Label("Histórico", systemImage: "folder")
      }
    }
  }
}
