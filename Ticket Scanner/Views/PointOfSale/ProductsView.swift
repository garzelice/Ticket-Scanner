//
//  Product.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 16.03.25.
//

import SwiftUI

struct ProductsView: View {
	@Environment(PointOfSaleViewModel.self) private var viewModel
	
	let products: [ViewConfig]
	var body: some View {
		ForEach(products) { config in
			VStack(alignment: .leading, spacing: -8) {
				Text(config.product.title ?? "No Title")
					.font(.caption2)
					.textCase(.uppercase)
					.foregroundStyle(Color.gray)
					.padding()
				VStack(alignment: .leading, spacing: 0) {
					AsyncImage(url: URL(string: config.product.images?.first?.url ?? "")){ image in
						image.resizable()
							.scaledToFill()
					} placeholder: {
						Color.red
					}
					.frame(height: 128)
					.clipShape(.rect(cornerRadius: 0))
					
					VStack(alignment: .leading, spacing: 4) {
						if config.selectedVariants.isEmpty {
							Text("Nothing Selected")
								.monospaced()
								.padding(.horizontal, 12)
						} else {
							ForEach(config.selectedVariants) { variantConfig in
								Text("\(variantConfig.amount) × \(variantConfig.variant.title ?? "No Variant Title")")
							}
						}
						
						
						Button {
							viewModel.openProduct = config
						} label: {
							Text("Select")
								.frame(maxWidth: .infinity)
								.font(.system(size: 17))
						}
						.buttonStyle(.bordered)
						.tint(.primary)
						.monospaced()
					}
					.padding(4)
				}
				.background(Color(UIColor.systemBackground))
				.clipShape(.rect(cornerRadius: 12))
			}
		}
	}
}

#Preview {
	ProductsView(products: [ViewConfig(product: MockData().products.first!, selectedVariants: [])])
}
