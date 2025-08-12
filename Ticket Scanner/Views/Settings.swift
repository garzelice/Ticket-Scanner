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
    @State private var serverUrlInput: String = ""
    @State private var isTestingUrl = false
    @State private var testError: String?

    @State private var faceIdEnabled = false
    @State private var showAnimations = false

    var body: some View {
        NavigationStack {
            List {
                serverSection
                appSection
                authSection
            }
            .navigationTitle("Settings")
        }
        .onAppear { if serverUrlInput.isEmpty { serverUrlInput = auth.medusaUrl ?? "" } }
        .alert("Error", isPresented: .constant(testError != nil)) {
            Button("OK") { testError = nil }
        } message: { Text(testError ?? "Unknown error") }
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
                            Text(url)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                        }
                        Spacer()
                        Button(editingServer ? "Cancel" : "Edit") {
                            withAnimation { toggleEditing(existing: url) }
                        }
                    }
                    if editingServer { editServerForm }
                }
                .padding(.vertical, 4)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No server configured").foregroundStyle(.secondary)
                    editServerForm
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func toggleEditing(existing: String) {
        if editingServer { // cancelling
            serverUrlInput = existing
            testError = nil
            isTestingUrl = false
        } else {
            serverUrlInput = existing
        }
        editingServer.toggle()
    }

    private var editServerForm: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("https://your-medusa-server.com", text: $serverUrlInput)
                .textContentType(.URL)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .disabled(isTestingUrl)
            if let testError { Text(testError).font(.caption).foregroundStyle(.red) }
            HStack {
                Button(role: .destructive) {
                    auth.logout()
                    medusa.isAuthenticated = false
                    serverUrlInput = ""
                } label: {
                    Label("Remove", systemImage: "trash")
                }
                .disabled(auth.medusaUrl == nil)
                Spacer()
                Button(action: testAndSaveServer) {
                    if isTestingUrl { ProgressView() } else { Text("Save") }
                }
                .disabled(isTestingUrl || serverUrlInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .buttonStyle(.borderedProminent)
            }
        }
        .animation(.default, value: isTestingUrl)
    }

    private func testAndSaveServer() {
        let url = serverUrlInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !url.isEmpty else { return }
        testError = nil
        isTestingUrl = true
        DispatchQueue.global().async {
            defer { DispatchQueue.main.async { isTestingUrl = false } }
            guard URL(string: url) != nil else {
                DispatchQueue.main.async { testError = "Invalid URL" }
                return
            }
            Thread.sleep(forTimeInterval: 0.5)
            DispatchQueue.main.async {
                auth.setServerUrl(url)
                if auth.storeName == nil { auth.setStoreName("Medusa Store") }
                withAnimation { editingServer = false }
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
