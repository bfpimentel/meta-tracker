import APIClient
import ComposableArchitecture
import DatabaseClient
import SwiftUI

public struct AppState: Equatable {
  public init() {}
}

public struct AppAction: Equatable {}

public struct AppEnvironment {
  public var api: APIClient
  public var db: DatabaseClient

  public init(api: APIClient, db: DatabaseClient) {
    self.api = api
    self.db = db
  }
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, env in
  .none
}

public struct AppView: View {
  let store: Store<AppState, AppAction>

  public init(store: Store<AppState, AppAction>) {
    self.store = store
  }

  @State private var text = ""
  @State private var items: [String] = []

  public var body: some View {
    SearchNavigation(text: $text) {
      withAnimation { items.append(text) }
    } cancel: {
      text = ""
    } content: {
      List(items, id: \.self) { item in
        Text(item)
      }
      .listStyle(PlainListStyle())
      .navigationTitle("Meta Tracker")
    }
    .edgesIgnoringSafeArea(.top)
  }
}
