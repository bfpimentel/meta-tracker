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

  public var body: some View {
    Text("Hello World")
  }
}
