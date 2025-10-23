//
//  Settings.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 08.03.25.
//

import SwiftUI

struct Settings: View {
    @Environment(Medusa.self) private var medusa
    @Environment(Auth.self) private var auth

    @State private var editingServer = false

    @State private var faceIdEnabled = false
    @State private var showAnimations = false

    var body: some View {
        NavigationStack {
            List {
                serverSection
                appSection
                authSection
            }
			.sheet(isPresented: $editingServer, content: {
				LoginView()
			})
            .navigationTitle("Settings")
        }
    }

    // MARK: Server Section
    private var serverSection: some View {
        Section("Server") {
            if let url = auth.medusaUrl {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(auth.storeName ?? "Store")
                                .font(.headline)
							Text(url.formatted())
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                        }
                        Spacer()
                        Button("Edit") {
                            editingServer = true
                        }
                    }
                }
                .padding(.vertical, 4)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No server configured").foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: App Section
    private var appSection: some View {
        Section("Ticket Scanner") {
            Toggle("Show Animations", isOn: $showAnimations)
            Toggle("Face ID", isOn: $faceIdEnabled)
        }
    }

    // MARK: Auth Section
    private var authSection: some View {
        Section("Account") {
            if auth.isAuthenticated {
                Button(role: .destructive) {
                    auth.logout()
                    medusa.isAuthenticated = false
                } label: {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                }
            } else {
                Text("Not logged in").foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    @Previewable @State var medusa = Medusa()
    @Previewable @State var auth = Auth()
    Settings()
        .environment(medusa)
        .environment(auth)
}
