//
//  SalesChannelSection.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 16.03.25.
//

import SwiftUI

struct SalesChannelSection: View {
	@Environment(Medusa.self) private var medusa
	@Environment(PointOfSaleViewModel.self) private var viewModel
	
    var body: some View {
		ForEach(viewModel.selectedSalesChannels) { salesChannel in
			Section(salesChannel.salesChannel.name ?? "No SalesChannel Name") {
				LazyVGrid(columns: viewModel.adaptiveColumn, alignment: .leading, spacing: 20) {
					ProductsView(products: salesChannel.products)
				}
			}
		}
    }
}

#Preview {
    SalesChannelSection()
}
