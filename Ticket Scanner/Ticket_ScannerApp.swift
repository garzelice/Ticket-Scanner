//
//  Ticket_ScannerApp.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 08.03.25.
//

import SwiftData
import SwiftUI

@main
struct Ticket_ScannerApp: App {
    @State private var medusa = Medusa()
	@State var auth: Auth = .init()
    @StateObject var authentication = Authentication()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isAuthenticated {
                    ContentView()
                } else {
                    LoginView()
                }
            }
            .task {
                // Attempt token refresh on launch to re-auth silently.
                await auth.refresh()
                // Mirror into medusa for any legacy usage
                medusa.isAuthenticated = auth.isAuthenticated
            }
            .onChange(of: auth.isAuthenticated) { _, newValue in
                medusa.isAuthenticated = newValue
            }
            .environment(medusa)
            .environment(auth)
        }
        .modelContainer(sharedModelContainer)
    }
}
