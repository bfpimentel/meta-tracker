//
//  MetaTrackerApp.swift
//  Shared
//
//  Created by Guilherme Souza on 17/05/21.
//

import SwiftUI

@main
struct MetaTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
