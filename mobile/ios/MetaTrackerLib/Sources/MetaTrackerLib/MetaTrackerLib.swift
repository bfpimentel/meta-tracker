import APIClient
import AnalyticsClient
import ComposableArchitecture
import DatabaseClient
import Models
import OSLog
import SwiftUI

public struct AppState: Equatable {

  public var searchText: String
  public var items: [Tracking.Event]
  public var isSearchInFlight: Bool

  public init(
    searchText: String = "",
    items: [Tracking.Event] = [],
    isSearchInFlight: Bool = false
  ) {
    self.searchText = searchText
    self.items = items
    self.isSearchInFlight = isSearchInFlight
  }
}

public enum AppAction: Equatable {
  case appDelegate(AppDelegateAction)
  case searchTextChanged(String)
  case searchCommited
  case searchCanceled

  case searchResults(Result<[Tracking.Event], NSError>)
}

public enum AppDelegateAction: Equatable {
  case didFinishLaunching
}

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

public let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, env in
  struct CancellationId: Hashable {}

  switch action {
  case .appDelegate(.didFinishLaunching):
    return .concatenate(
      .fireAndForget { env.analytics.initialize() },
      .fireAndForget { env.analytics.track(.appLaunched) }
    )

  case .searchTextChanged(let text):
    state.searchText = text
    return .none

  case .searchCommited:
    state.isSearchInFlight = true
    return env.api
      .trackings(state.searchText.components(separatedBy: ","))
      .cancellable(id: CancellationId(), cancelInFlight: true)
      .receive(on: env.mainQueue)
      .mapError { $0 as NSError }
      .map {
        $0.flatMap {
          $0.events
            .sorted { $0.trackedAt > $1.trackedAt }
        }
      }
      .catchToEffect()
      .map(AppAction.searchResults)

  case .searchCanceled:
    state.isSearchInFlight = false
    return .concatenate(
      .init(value: .searchTextChanged("")),
      .cancel(id: CancellationId())
    )

  case let .searchResults(.success(items)):
    state.items = items
    state.isSearchInFlight = false
    return .none

  case let .searchResults(.failure(error)):
    state.isSearchInFlight = false
    return .none
  }
}

public struct AppView: View {
  let store: Store<AppState, AppAction>

  public init(store: Store<AppState, AppAction>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store) { viewStore in
      SearchNavigation(
        text: viewStore.binding(get: \.searchText, send: AppAction.searchTextChanged)
      ) {
        withAnimation {
          viewStore.send(.searchCommited)
        }
      } cancel: {
        viewStore.send(.searchCanceled)
      } content: {
        Group {
          if viewStore.isSearchInFlight {
            ProgressView()
          } else {
            List {
              ForEach(viewStore.items, content: rowView)
            }
          }
        }
        .navigationTitle("Meta Tracker")
      }
      .edgesIgnoringSafeArea(.top)
    }
  }

  private func rowView(_ model: Tracking.Event) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(model.description)
      Text(dateFormatter.string(from: model.trackedAt))
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .padding(.vertical, 8)
  }
}

let dateFormatter = { () -> DateFormatter in
  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "pt_BR")
  formatter.dateStyle = .short
  formatter.timeStyle = .short
  return formatter
}()
