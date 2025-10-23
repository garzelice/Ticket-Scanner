//
//  ScanView.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 08.03.25.
//

import SwiftUI
import CodeScanner

struct ScanView: View {
	@Environment(Medusa.self) private var medusa
	@Environment(Auth.self) private var auth
	
	@State private var isShowingScanner = false
	@State private var isShowingNFC = false
	
	func handleScan(result: Result<ScanResult, ScanError>) {
	   isShowingScanner = false
	}
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					HStack(spacing: 12) {
						Button {
							isShowingScanner = true
						} label: {
							Label("Scan QR Code", systemImage: "qrcode.viewfinder")
								.frame(maxWidth: .infinity)
						}
						.buttonStyle(LargeButton())

						Button {
							// Placeholder for NFC scan action
							isShowingNFC = true
						} label: {
							Label("Scan NFC", systemImage: "wave.3.left")
								.frame(maxWidth: .infinity)
						}
						.buttonStyle(LargeButton())
					}
					.listRowInsets(EdgeInsets())
				}

				Section("Sold Tickets") {
					if medusa.tickets.isEmpty {
						ContentUnavailableView("No Tickets", systemImage: "ticket", description: Text("Tickets you scan will appear here."))
					} else {
						ForEach(medusa.tickets, id: \.id) { ticket in
							VStack(alignment: .leading, spacing: 4) {
								Text(ticket.id ?? "Unknown ID")
									.font(.headline)
								if let status = ticket.status { Text(status).font(.subheadline).foregroundStyle(.secondary) }
								if let created = ticket.created_at { Text(created).font(.caption2).foregroundStyle(.tertiary) }
							}
						}
					}
				}
			}
			.listStyle(.insetGrouped)
			.sheet(isPresented: $isShowingScanner) {
				CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: handleScan)
			}
			.navigationTitle("Scan Tickets")
			.onAppear {
				Task {
					await medusa.getTickets(auth: auth)
				}
			}
		}
	}
}

#Preview {
	@Previewable @State var medusa = Medusa()
	ScanView()
		.environment(medusa)
}
