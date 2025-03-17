//
//  AddSalesChannelButton.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 17.03.25.
//


import SwiftUI

struct AddSalesChannelButton: View {
    @Environment(PointOfSaleViewModel.self) private var viewModel
    
    var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Section {
				Button {
					viewModel.salesChannelSelectOpen = true
				} label: {
					Image(systemName: "plus.circle")
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(LargeButton())
			} header: {
				Text("Add Sales Channel")
					.monospaced()
					.multilineTextAlignment(.leading)
					.padding(.leading, 16)
			}
		}
    }
}