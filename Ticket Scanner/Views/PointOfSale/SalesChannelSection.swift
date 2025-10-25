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
			if let salesChannel = viewModel.selectedSalesChannel {
				Section {
					LazyVGrid(columns: viewModel.adaptiveColumn, alignment: .leading, spacing: 20) {
						ProductsView(products: salesChannel.products)
					}
					.padding(.bottom, 32)
				} header: {
					Text(salesChannel.salesChannel.name ?? "No SalesChannel Name")
						.monospaced()
						.multilineTextAlignment(.leading)
						.padding(.leading, 16)
				}
				.transition(.scale)
			}
		}
	}
}

//#Preview {
//	@Previewable @State var viewModel = PointOfSaleViewModel(selectedSalesChannels: SelectedSalesChannel.examples())
//	@Previewable @State var medusa = Medusa
//	
//	ScrollView {
//		SalesChannelSection()
//			.environment(viewModel)
//			.environment(medusa)
//	}
//}
