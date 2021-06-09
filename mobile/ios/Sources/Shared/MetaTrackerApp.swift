//
//  MetaTrackerApp.swift
//  Shared
//
//  Created by Guilherme Souza on 17/05/21.
//

import AppEnvironment
import AppTelemetryClient
import ComposableArchitecture
import MetaTrackerLib
import OSLog
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {

  let store = Store(
    initialState: .init(),
    reducer: appReducer,
    environment: .live
  )

  lazy var viewStore = ViewStore(store.scope(state: { _ in () }))

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    viewStore.send(.appDelegate(.didFinishLaunching))
    return true
  }
}

@main
struct MetaTrackerApp: App {

  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

  var body: some Scene {
    WindowGroup {
      AppView(store: appDelegate.store)
    }
  }
}

extension AppEnvironment {
  static let live = Self(
    api: .live,
    db: .live,
    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
    analytics: .appTelemetry
      //    log: Logger(subsystem: Bundle.main.bundleIdentifier ?? "br.dev.native.metatracker", category: "main")
  )
}
