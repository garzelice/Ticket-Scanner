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
	
	@State private var isShowingScanner = false
	
	func handleScan(result: Result<ScanResult, ScanError>) {
	   isShowingScanner = false
	}
	
	var body: some View {
		NavigationStack {
			VStack {
				Button {
					isShowingScanner = true
				} label: {
					Text("Scan QR Code")
				}
			}
			.sheet(isPresented: $isShowingScanner) {
				CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: handleScan)
			}
			.navigationTitle("Scan Tickets")
		}
	}
}

#Preview {
	@Previewable @State var medusa = Medusa()
	ScanView()
		.environment(medusa)
}
