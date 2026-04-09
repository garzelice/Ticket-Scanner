//
//  Ticket_ScannerApp.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 08.03.25.
//

import Dependencies
import SwiftData
import SwiftUI

@main
struct Ticket_ScannerApp: App {
    @State private var medusa = Medusa()
    @State var auth: Auth = .init()
    @StateObject var authentication = Authentication()
    @State private var networkMonitor = NetworkMonitor()

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

    init() {
        prepareDependencies {
            try! $0.bootstrapDatabase()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await auth.refresh()
                    medusa.isAuthenticated = auth.isAuthenticated
                    if networkMonitor.isOnline {
                        await medusa.syncTickets(auth: auth, isOnline: true)
                    } else {
                        await medusa.loadTickets()
                    }
                }
                .onChange(of: networkMonitor.isOnline) { _, isOnline in
                    if isOnline {
                        Task {
                            await medusa.syncPendingScans(auth: auth, isOnline: true)
                        }
                    }
                }
            .sheet(isPresented: .constant(!auth.isAuthenticated), content: {
                LoginView()
            })
            .interactiveDismissDisabled(true)
            .onChange(of: auth.isAuthenticated) { _, newValue in
                medusa.isAuthenticated = newValue
            }
            .environment(medusa)
            .environment(auth)
            .environment(networkMonitor)
        }
        .modelContainer(sharedModelContainer)
    }
}
