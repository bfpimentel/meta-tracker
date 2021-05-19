//
//  MetaTrackerApp.swift
//  Shared
//
//  Created by Guilherme Souza on 17/05/21.
//

import ComposableArchitecture
import MetaTrackerLib
import SwiftUI

@main
struct MetaTrackerApp: App {
  var body: some Scene {
    WindowGroup {
      AppView(
        store: Store(
          initialState: AppState(),
          reducer: appReducer,
          environment: AppEnvironment.live
        )
      )
    }
  }
}

extension AppEnvironment {
  static let live = Self(
    api: .live,
    db: .live,
    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
  )
}
