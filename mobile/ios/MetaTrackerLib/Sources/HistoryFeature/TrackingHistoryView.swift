//  Created by Guilherme Souza on 09/06/21.
//

import ComposableArchitecture
import DatabaseClient
import Models
import SwiftUI

public struct TrackingHistoryState: Equatable {
  public var entries: [TrackingHistory.Entry]

  public init(entries: [TrackingHistory.Entry] = []) {
    self.entries = entries
  }
}

public enum TrackingHistoryAction: Equatable {
  case didAppear
  case entriesLoaded(Result<[TrackingHistory.Entry], NSError>)
}

public struct TrackingHistoryEnvironment {
  public let db: DatabaseClient

  public init(db: DatabaseClient) {
    self.db = db
  }
}

public let trackingHistoryReducer = Reducer<
  TrackingHistoryState, TrackingHistoryAction, TrackingHistoryEnvironment
> { state, action, env in
  switch action {
  case .didAppear:
    return env.db.fetchTrackingHistory()
      .mapError { $0 as NSError }
      .catchToEffect()
      .map(TrackingHistoryAction.entriesLoaded)

  case let .entriesLoaded(.success(entries)):
    state.entries = entries
    return .none

  case .entriesLoaded(.failure):
    return .none
  }
}

public struct TrackingHistoryView: View {

  private let store: Store<TrackingHistoryState, TrackingHistoryAction>

  public init(store: Store<TrackingHistoryState, TrackingHistoryAction>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store) { viewStore in
      NavigationView {
        List(viewStore.entries, id: \.code) { entry in
          VStack(alignment: .leading, spacing: 4) {
            Text(entry.code)
            Text("Buscado em \(dateFormatter.string(from: entry.lastTrackedAt))")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
        .navigationTitle("Histórico")
      }
      .onAppear { viewStore.send(.didAppear) }
    }
  }
}

// TODO: already exists a dataformatter in other features, must reuse it.
let dateFormatter = { () -> DateFormatter in
  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "pt_BR")
  formatter.dateStyle = .short
  formatter.timeStyle = .short
  return formatter
}()

#if DEBUG
  struct TrackingHistoryView_Previews: PreviewProvider {
    static var previews: some View {
      TrackingHistoryView(
        store: Store(
          initialState: .init(),
          reducer: trackingHistoryReducer,
          environment: .init(db: .noop)
        )
      )
    }
  }
#endif
