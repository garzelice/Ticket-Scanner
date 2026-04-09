//
//  SalesChannelSelectionSheet.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 17.03.25.
//


import SwiftUI

struct SalesChannelSelectionSheet: View {
    @Environment(Medusa.self) private var medusa
    @Environment(PointOfSaleViewModel.self) private var viewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List(medusa.salesChannels) { salesChannel in
                Label(
                    salesChannel.name ?? "No Sales Channel Name",
                    systemImage: viewModel.selectedSalesChannels.contains(where: { $0.salesChannel == salesChannel }) ? "checkmark.circle.fill" : "circle"
                )
				.onTapGesture {
					withAnimation {
						viewModel.toggleSalesChannel(
							salesChannel: salesChannel,
							products: medusa.products.filter { product in
								guard let productSalesChannels = product.sales_channels else {
									return false
								}
								return productSalesChannels.contains(where: { $0 == salesChannel })
							}
						)
					}
				}
            }
            .navigationTitle("Select Sales Channel")
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}