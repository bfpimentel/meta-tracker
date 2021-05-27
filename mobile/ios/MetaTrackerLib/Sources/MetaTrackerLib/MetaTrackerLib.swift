import APIClient
import AnalyticsClient
import ComposableArchitecture
import DatabaseClient
import Models
import OSLog
import SwiftUI

public struct AppState: Equatable {

  public var searchText: String
  public var result: [Result<Tracking, TrackingError>]
  public var isSearchInFlight: Bool

  public init(
    searchText: String = "",
    result: [Result<Tracking, TrackingError>] = [],
    isSearchInFlight: Bool = false
  ) {
    self.searchText = searchText
    self.result = result
    self.isSearchInFlight = isSearchInFlight
  }
}

public enum AppAction: Equatable {
  case appDelegate(AppDelegateAction)
  case searchTextChanged(String)
  case searchCommited
  case searchCanceled
  case searchResults(Result<[Result<Tracking, TrackingError>], NSError>)
}

public enum AppDelegateAction: Equatable {
  case didFinishLaunching
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
      .catchToEffect()
      .map(AppAction.searchResults)

  case .searchCanceled:
    state.isSearchInFlight = false
    return .concatenate(
      .init(value: .searchTextChanged("")),
      .cancel(id: CancellationId())
    )

  case let .searchResults(.success(result)):
    state.result = result
    state.isSearchInFlight = false
    return .none

  case let .searchResults(.failure(error)):
    state.isSearchInFlight = false
    return .none
  }
}

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
              ForEach(viewStore.result, content: section)
            }
          }
        }
        .navigationTitle("Meta Tracker")
      }
      .edgesIgnoringSafeArea(.top)
    }
  }

  private func section(_ model: Result<Tracking, TrackingError>) -> some View {
    Section(header: Text(model.code)) {
      switch model {
      case .success(let tracking):
        ForEach(tracking.events) { event in
          VStack(alignment: .leading, spacing: 4) {
            Text(event.description)
            Text(dateFormatter.string(from: event.trackedAt))
              .font(.caption)
              .foregroundColor(.secondary)
          }
          .padding(.vertical, 8)
        }
      case .failure(let error):
        Text(error.message)
      }
    }
  }
}

let dateFormatter = { () -> DateFormatter in
  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "pt_BR")
  formatter.dateStyle = .short
  formatter.timeStyle = .short
  return formatter
}()
