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
	@Previewable @State var viewModel = PointOfSaleViewModel()
	@Previewable @State var medusa = Medusa(user: User(), server: Server(), products: MockData().products)
	
	SalesChannelSection()
		.environment(viewModel)
		.environment(medusa)
		.onAppear{
			medusa.getProducts()
			medusa.getSalesChannels()
			viewModel.selectedSalesChannels = medusa.salesChannels.map({ salesChannel in
				return SelectedSalesChannel(salesChannel: salesChannel, products: medusa.products.map({ product in
					return ViewConfig(product: product, selectedVariants: [])
				}))
			})
		}
}
