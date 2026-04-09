//
//  ScanView.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 08.03.25.
//

import SwiftUI
import CodeScanner
import Network
import Foundation

struct ScanView: View {
    @Environment(Medusa.self) private var medusa
    @Environment(Auth.self) private var auth
    @Environment(NetworkMonitor.self) private var networkMonitor
    
    @State private var isShowingScanner = false
    @State private var isShowingNFC = false
    @State private var lastScannedTicketHash: String?
    @State private var scanError: String?
    @State private var statusMessage: String?
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        scanError = nil
        
        switch result {
        case .success(let scanResult):
            let scannedHash = scanResult.string
            print(scannedHash)
            if let ticket = medusa.tickets.first(where: { $0.hash == scannedHash }) {
                if ticket.isScanned {
                    scanError = "Ticket already scanned"
                    lastScannedTicketHash = ticket.hash
                    triggerHapticFeedback(style: .error)
                } else {
                    Task {
                        await medusa.markTicketScanned(scannedHash, isOnline: networkMonitor.isOnline, auth: auth)
                    }
                    lastScannedTicketHash = ticket.hash
                    triggerHapticFeedback(style: .success)
                    withAnimation {
                        statusMessage = "Scanned: \(String(scannedHash.prefix(8)))"
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation { statusMessage = nil }
                    }
                }
            } else {
                scanError = "Unknown ticket"
                triggerHapticFeedback(style: .error)
            }
        case .failure(let error):
            scanError = error.localizedDescription
            triggerHapticFeedback(style: .error)
        }
    }
    
    private func triggerHapticFeedback(style: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(style)
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Banners section
                        VStack(spacing: 0) {
                            if !networkMonitor.isOnline {
                                StatusBanner(
                                    icon: "wifi.slash",
                                    text: "Offline Mode Active",
                                    subtext: "Scans will sync automatically",
                                    color: .orange
                                )
                            }
                            
                            if medusa.pendingSyncCount > 0 {
                                StatusBanner(
                                    icon: "arrow.triangle.2.circlepath",
                                    text: "\(medusa.pendingSyncCount) Pending Scans",
                                    subtext: medusa.isSyncing ? "Syncing now..." : "Waiting for connection",
                                    color: .blue
                                )
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 24) {
                            if let error = scanError {
                                ErrorBanner(message: error)
                                    .padding(.top, 16)
                            } else if let success = statusMessage {
                                SuccessBanner(message: success)
                                    .padding(.top, 16)
                            }
                            
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    if medusa.isSyncing {
                                        ProgressView()
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                                
                                if medusa.tickets.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "ticket.fill")
                                            .font(.system(size: 40))
                                            .foregroundStyle(.quaternary)
                                        Text("No tickets found.")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                } else {
                                    LazyVStack(spacing: 1) {
                                        ForEach(medusa.tickets, id: \.id) { ticket in
                                            TicketRowView(ticket: ticket)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 16)
                                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                        }
                                    }
//                                    .background(Color(UIColor.separator).opacity(0.3))
//                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        .padding(.bottom, 120) // Space for floating scanner button
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
                
                // Massive Floating Scan Action
                VStack {
                    Button {
                        triggerHapticFeedback(style: .success) // initial feedback
                        isShowingScanner = true
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 28, weight: .bold))
                            Text("Ticket Scannen")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: Color.accentColor.opacity(0.4), radius: 16, x: 0, y: 8)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "ticket-123", completion: handleScan)
                    .ignoresSafeArea()
            }
            .navigationTitle("Tickets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            triggerHapticFeedback(style: .success)
                            await medusa.syncTickets(auth: auth, isOnline: networkMonitor.isOnline)
                        }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .fontWeight(.semibold)
                            .rotationEffect(.degrees(medusa.isSyncing ? 360 : 0))
                            .animation(medusa.isSyncing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: medusa.isSyncing)
                    }
                    .disabled(medusa.isSyncing || !networkMonitor.isOnline)
                }
            }
            .onAppear {
                Task {
                    await medusa.loadTickets()
                }
            }
        }
    }
}

// MARK: - Components

struct StatusBanner: View {
    let icon: String
    let text: String
    let subtext: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.2))
                .clipShape(Circle())
                .overlay(Circle().stroke(color.opacity(0.5), lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(color)
                Text(subtext)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .overlay(alignment: .bottom) {
            Rectangle().frame(height: 1).foregroundStyle(color.opacity(0.2))
        }
    }
}

struct ErrorBanner: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
            Text(message)
                .font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.red.opacity(0.15))
        .foregroundStyle(Color.red)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

struct SuccessBanner: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
            Text(message)
                .font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.green.opacity(0.15))
        .foregroundStyle(Color.green)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}



struct TicketRowView: View {
    let ticket: TicketRecord
    @AppStorage("emailUnblurDuration") private var emailUnblurDuration: Double = 3.0
    @State private var isEmailVisible = false
    
    private let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    private let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
    
    var isEffectivelyScanned: Bool {
        ticket.isScanned || ticket.status?.lowercased() == "used" || ticket.status?.lowercased() == "scanned"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                if let orderId = ticket.orderDisplayId {
                    Text("#\(orderId)")
                        .font(.system(.title, design: .rounded).weight(.heavy))
                        .foregroundStyle(isEffectivelyScanned ? .secondary : .primary)
                        .strikethrough(isEffectivelyScanned)
                } else {
                    Text(ticket.hash?.prefix(10) ?? "Unknown")
                        .font(.system(.headline, design: .monospaced).weight(.bold))
                        .foregroundStyle(isEffectivelyScanned ? .secondary : .primary)
                        .strikethrough(isEffectivelyScanned)
                }
                
                if let email = ticket.customerEmail {
                    Text(email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .blur(radius: isEmailVisible ? 0 : 8)
                        .animation(.easeInOut, value: isEmailVisible)
                        .onTapGesture {
                            if !isEmailVisible {
                                isEmailVisible = true
                                Task {
                                    try? await Task.sleep(for: .seconds(emailUnblurDuration))
                                    await MainActor.run {
                                        isEmailVisible = false
                                    }
                                }
                            }
                        }
                }
                
                HStack(spacing: 8) {
                    if isEffectivelyScanned {
                        Text((ticket.isScanned ? "SCANNED" : ticket.status?.uppercased()) ?? "SCANNED")
                            .font(.system(.caption, design: .rounded).weight(.bold))
                            .foregroundStyle(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    } else if let status = ticket.status {
                        Text(status.uppercased())
                            .font(.system(.caption, design: .rounded).weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    if let created = ticket.createdAt,
                    let createdDate = formatter.date(from: created){
                        Text(createdDate, format: .dateTime.day().month().year())
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }
                .padding(.top, 2)
            }
            
            Spacer(minLength: 16)
            
            if isEffectivelyScanned {
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.green)
                    if let scannedAt = ticket.scannedAt {
                        Text(relativeFormatter.localizedString(for: scannedAt, relativeTo: Date.now))
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
            } else if ticket.needsSync {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.orange)
            }
        }
        .opacity(isEffectivelyScanned ? 0.6 : 1.0)
    }
}

// MARK: - Helpers

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    @Previewable @State var medusa = Medusa()
    @Previewable @State var networkMonitor = NetworkMonitor()
    ScanView()
        .environment(medusa)
        .environment(networkMonitor)
}
