import APIClient
import ComposableArchitecture
import DatabaseClient
import SwiftUI

public struct AppState: Equatable {

  public var searchText: String
  public var items: [String]
  public var isSearchInFlight: Bool

  public init(
    searchText: String = "",
    items: [String] = [],
    isSearchInFlight: Bool = false
  ) {
    self.searchText = searchText
    self.items = items
    self.isSearchInFlight = isSearchInFlight
  }
}

public enum AppAction: Equatable {
  case searchTextChanged(String)
  case searchCommited
  case searchCanceled

  case searchResults(Result<[String], NSError>)
}

public struct AppEnvironment {
  public var api: APIClient
  public var db: DatabaseClient
  public var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(api: APIClient, db: DatabaseClient, mainQueue: AnySchedulerOf<DispatchQueue>) {
    self.api = api
    self.db = db
    self.mainQueue = mainQueue
  }
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, env in
  switch action {
  case .searchTextChanged(let text):
    state.searchText = text
    return .none

  case .searchCommited:
    struct CancellationId: Hashable {}
    state.isSearchInFlight = true

    return env.api
      .trackings(state.searchText.components(separatedBy: ","))
      .cancellable(id: CancellationId())
      .receive(on: env.mainQueue)
      .mapError { $0 as NSError }
      .map {
        $0.flatMap {
          $0.events.map(\.description)
            .joined(separator: "\n")
        }
      }
      .catchToEffect()
      .map { AppAction.searchResults($0) }

  case .searchCanceled:
    return .init(value: .searchTextChanged(""))

  case let .searchResults(.success(items)):
    state.items = items
    state.isSearchInFlight = false
    return .none

  case .searchResults(.failure):
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
            List(viewStore.items, id: \.self) { item in
              Text(item)
            }
            .listStyle(PlainListStyle())
          }
        }
        .navigationTitle("Meta Tracker")
      }
      .edgesIgnoringSafeArea(.top)
    }
  }
}
