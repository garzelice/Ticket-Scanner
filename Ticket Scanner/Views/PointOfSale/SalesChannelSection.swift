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
		VStack(alignment: .leading, spacing: 0) {
			ForEach(viewModel.selectedSalesChannels) { salesChannel in
				Section {
					LazyVGrid(columns: viewModel.adaptiveColumn, alignment: .leading, spacing: 20) {
						ProductsView(products: salesChannel.products)
					}
				} header: {
					Text(salesChannel.salesChannel.name ?? "No SalesChannel Name")
						.monospaced()
						.multilineTextAlignment(.leading)
						.padding(.top, 32)
						.padding(.leading, 16)
				}
			}
		}
	}
}

#Preview {
	@Previewable @State var viewModel = PointOfSaleViewModel(selectedSalesChannels: SelectedSalesChannel.examples())
	@Previewable @State var medusa = Medusa(user: User(), server: Server(), products: Product.examples())
	
	ScrollView {
		SalesChannelSection()
			.environment(viewModel)
			.environment(medusa)
	}
}
