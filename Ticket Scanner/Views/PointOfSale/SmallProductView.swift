//
//  ProductsView.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 16.03.25.
//

import SwiftUI

struct SmallProductView: View {
	@Environment(PointOfSaleViewModel.self) private var viewModel
	
	let config: ViewConfig
	
	var amount: Int {
		if let variant = config.product.variants?.first {
			return viewModel.getVariantAmount(config: config, variant: variant)
		}
		return 0
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: -8) {
			Text(config.product.title != nil ? "№ \(config.product.title!)" : "No Title")
				.font(.caption2)
				.textCase(.uppercase)
				.foregroundStyle(Color.gray)
				.padding()
			
				HStack {
					if let variant = config.product.variants?.first {
						Text("\(amount)")
							.contentTransition(.numericText(value: Double(amount)))
							.animation(.linear(duration: 0.2), value: amount)
							.monospaced()
						Spacer()
						Stepper {} onIncrement: {
							viewModel.addProductToCard(config: config,variant: variant)
						} onDecrement: {
							viewModel.removeProductFromCard(config: config, variant: variant)
						}
					}
				}
				.padding()
			
			.background(Color(UIColor.systemBackground))
			.clipShape(.rect(cornerRadius: 12))
			// Add an ID to force refresh when openProduct changes
			.id(viewModel.openProduct?.selectedVariants.description)
		}
		
	}
}

#Preview {
	@Previewable @State var viewModel = PointOfSaleViewModel()
	
	NavigationView {
		SmallProductView(config: ViewConfig.example())
			.environment(viewModel)
	}
	.background(Color(UIColor.secondarySystemBackground))
}
