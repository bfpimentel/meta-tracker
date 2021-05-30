//  Created by Guilherme Souza on 30/05/21.

import APIClient
import ComposableArchitecture
import Models
import SwiftUI

public struct SearchState: Equatable {
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

public enum SearchAction: Equatable {
  case searchTextChanged(String)
  case searchCommited
  case searchCanceled
  case searchResults(Result<[Result<Tracking, TrackingError>], NSError>)
}

struct SearchEnvironment {
  var api: APIClient
  var mainQueue: AnySchedulerOf<DispatchQueue>
}

extension AppEnvironment {
  var searchEnvironment: SearchEnvironment {
    SearchEnvironment(api: api, mainQueue: mainQueue)
  }
}

let searchReducer = Reducer<SearchState, SearchAction, SearchEnvironment> { state, action, env in
  struct CancellationId: Hashable {}

  switch action {
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
      .map(SearchAction.searchResults)

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

struct SearchView: View {

  let store: Store<SearchState, SearchAction>

  var body: some View {
    WithViewStore(store) { viewStore in
      SearchNavigation(
        text: viewStore.binding(get: \.searchText, send: SearchAction.searchTextChanged)
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

#if DEBUG
  struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
      SearchView(
        store: Store(
          initialState: .init(),
          reducer: searchReducer,
          environment: SearchEnvironment(
            api: .live,
            mainQueue: DispatchQueue.main.eraseToAnyScheduler()
          )
        )
      )
    }
  }
#endif
