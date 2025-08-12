//
//  LoginView.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 08.03.25.
//

import SwiftUI

struct LoginView: View {
    @Environment(Medusa.self) private var medusa // Existing environment controlling app gating
    @Environment(Auth.self) private var auth     // New Auth environment object for persistence
    @StateObject private var loginVM = LoginViewModel()

    // Step management
    @State private var isTestingUrl = false
    @State private var testError: String?
    @State private var serverUrlInput: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var authenticating = false
    @State private var showPassword = false
    @FocusState private var focusedField: Field?

    private enum Field { case url, email, password }

    // Derived flags
    private var hasPersistedServer: Bool { auth.medusaUrl != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if !hasPersistedServer {
                        serverUrlEntry
                    } else {
                        serverSummaryCard
                        loginForm
                    }
                }
                .padding()
            }
            .navigationTitle("Login")
            .toolbar { toolbarContent }
        }
        .interactiveDismissDisabled(authenticating)
        .alert("Error", isPresented: .constant(testError != nil && !authenticating)) {
            Button("OK") { testError = nil }
        } message: {
            Text(testError ?? "Unknown error")
        }
    }

    // MARK: - Step 1: URL Entry & Test
    private var serverUrlEntry: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Step 1: Enter Medusa Server URL")
                .font(.headline)
            TextField("https://your-medusa-server.com", text: $serverUrlInput)
                .textContentType(.URL)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .url)
                .submitLabel(.go)
                .onSubmit { testServerUrl() }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))

            if let testError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.yellow)
                    Text(testError).font(.caption).foregroundStyle(.secondary)
                }
                .transition(.opacity)
            }

            Button(action: testServerUrl) {
                if isTestingUrl {
                    ProgressView().progressViewStyle(.circular)
                } else {
                    Label("Test & Save Server", systemImage: "network")
                }
            }
            .disabled(isTestingUrl || serverUrlInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            if serverUrlInput.isEmpty, let existing = auth.medusaUrl { serverUrlInput = existing }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { focusedField = .url }
        }
    }

    private func testServerUrl() {
        let url = serverUrlInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !url.isEmpty else { return }
        testError = nil
        isTestingUrl = true
        // Placeholder test: basic URL validation. Replace with actual ping later.
        DispatchQueue.global().async {
            defer { DispatchQueue.main.async { isTestingUrl = false } }
            if URL(string: url) == nil {
                DispatchQueue.main.async { testError = "Invalid URL" }
                return
            }
            // Simulate network delay.
            Thread.sleep(forTimeInterval: 0.6)
            DispatchQueue.main.async {
                auth.setServerUrl(url)
                // Placeholder: set a fake store name until real fetch is implemented.
                if auth.storeName == nil { auth.setStoreName("Medusa Store") }
            }
        }
    }

    // MARK: - Step 2: Summary Card
    private var serverSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(auth.storeName ?? "Store")
                        .font(.title2.weight(.semibold))
                    if let url = auth.medusaUrl {
                        Text(url)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                }
                Spacer()
                Button {
                    withAnimation {
                        // Editing resets server persistence but keeps existing input for convenience
                        let existing = auth.medusaUrl
                        auth.logout() // Clears token + store name + url
                        if let existing { serverUrlInput = existing }
                    }
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .buttonStyle(.bordered)
            }

            Divider()
            Text("Enter your credentials to continue.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Login Form
    private var loginForm: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("you@example.com", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Group {
                    if showPassword {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                }
                .textContentType(.password)
                .focused($focusedField, equals: .password)
                .submitLabel(.go)
                .onSubmit { attemptLogin() }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                .overlay(alignment: .trailing) {
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.trailing, 12)
                }
            }

            Button(action: attemptLogin) {
                if authenticating {
                    ProgressView()
                } else {
                    Label("Login", systemImage: "arrow.right.circle.fill")
                        .font(.headline)
                }
            }
            .disabled(!canAttemptLogin)
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 8)
    }

    private var canAttemptLogin: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        !authenticating &&
        auth.medusaUrl != nil
    }

    private func attemptLogin() {
        guard canAttemptLogin, let url = auth.medusaUrl else { return }
        authenticating = true
        testError = nil
        Task {
            do {
                try await auth.authenticate(url: url, email: email, password: password)
                await MainActor.run {
                    withAnimation { medusa.isAuthenticated = true }
                }
            } catch {
                await MainActor.run {
                    testError = error.localizedDescription
                }
            }
            await MainActor.run { authenticating = false }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") { focusedField = nil }
        }
    }
}

#Preview {
    LoginView()
}
