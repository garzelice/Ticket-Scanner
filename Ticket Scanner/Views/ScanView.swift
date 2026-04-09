//
//  ScanView.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 08.03.25.
//

import SwiftUI
import CodeScanner
import Network

struct ScanView: View {
    @Environment(Medusa.self) private var medusa
    @Environment(Auth.self) private var auth
    @Environment(NetworkMonitor.self) private var networkMonitor
    
    @State private var isShowingScanner = false
    @State private var isShowingNFC = false
    @State private var lastScannedTicketHash: String?
    @State private var scanError: String?
    
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
                } else {
                    Task {
                        await medusa.markTicketScanned(scannedHash, isOnline: networkMonitor.isOnline, auth: auth)
                    }
                    lastScannedTicketHash = ticket.hash
                }
            } else {
                scanError = "Unknown ticket"
            }
        case .failure(let error):
            scanError = error.localizedDescription
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                List {
                    if !networkMonitor.isOnline {
                        Section {
                            HStack {
                                Image(systemName: "wifi.slash")
                                    .foregroundStyle(.orange)
                                Text("Offline - scans will sync when online")
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                    
                    if medusa.pendingSyncCount > 0 {
                        Section {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .foregroundStyle(.orange)
                                Text("\(medusa.pendingSyncCount) scan(s) pending sync")
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                    
                    Section("Sold Tickets") {
                        if medusa.tickets.isEmpty {
                            ContentUnavailableView("No Tickets", systemImage: "ticket", description: Text("Sold Tickets will appear here."))
                        } else {
                            ForEach(medusa.tickets, id: \.id) { ticket in
                                TicketRowView(ticket: ticket)
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    if let error = scanError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                            Text(error)
                                .foregroundStyle(.red)
                        }
                    }
                    
                    HStack {
                        Text("Scan Method")
                            .font(.title2)
                        Spacer()
                        if medusa.isSyncing {
                            ProgressView()
                        }
                    }
                    HStack {
                        Button {
                            isShowingScanner = true
                        } label: {
                            Label("QR Code", systemImage: "qrcode.viewfinder")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button {
                            isShowingNFC = true
                        } label: {
                            Label("NFC", systemImage: "wave.3.left")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(true)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .frame(maxWidth: .infinity)
                .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 10, topTrailing: 10)))
            }
            .listStyle(.insetGrouped)
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "ticket-123", completion: handleScan)
            }
            .navigationTitle("Scan Tickets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await medusa.syncTickets(auth: auth, isOnline: networkMonitor.isOnline)
                        }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    .disabled(medusa.isSyncing || !networkMonitor.isOnline)
                }
            }
            .onAppear {
                Task {
                    await medusa.loadTickets()
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .toolbarBackground(Color(UIColor.systemBackground), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct TicketRowView: View {
    let ticket: TicketRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(ticket.hash ?? "No Hash Available")
                    .font(.headline)
                if let status = ticket.status { 
                    Text(status).font(.subheadline).foregroundStyle(.secondary) 
                }
                if let created = ticket.createdAt { 
                    Text(created).font(.caption2).foregroundStyle(.tertiary) 
                }
            }
            Spacer()
            if ticket.isScanned {
                VStack(alignment: .trailing, spacing: 2) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    if let scannedAt = ticket.scannedAt {
                        Text(scannedAt, style: .time)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            } else if ticket.needsSync {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundStyle(.orange)
            }
        }
    }
}

#Preview {
    @Previewable @State var medusa = Medusa()
    @Previewable @State var networkMonitor = NetworkMonitor()
    ScanView()
        .environment(medusa)
        .environment(networkMonitor)
}
