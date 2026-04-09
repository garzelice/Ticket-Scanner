//
//  SelectVariants.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 14.03.25.
//

import SwiftUI

struct SelectVariants: View {
	@Environment(PointOfSaleViewModel.self) private var viewModel

	func getCurrent(variant: Variants) -> Int {
		if let openProduct = viewModel.openProduct {
			return viewModel.getVariantAmount(config: openProduct, variant: variant)
		}
		return 0
	}

	var body: some View {
		if let variants = viewModel.openProduct?.product.variants {
			if let openProduct = viewModel.openProduct {
				Form {
					ForEach(variants, id: \.id) { variant in
						let variant = variants[0]
						HStack {
							Text(
								variant.title != nil
									? "\(getCurrent(variant: variant)) × \(variant.title!)"
									: "No Title"
							)
							.monospaced()
							Spacer()
							Stepper {
							} onIncrement: {
								viewModel.addProductToCard(config: openProduct, variant: variant)
							} onDecrement: {
								viewModel.removeProductFromCard(
									config: openProduct, variant: variant)
							}
							.sensoryFeedback(.increase, trigger: getCurrent(variant: variant))
							.frame(width: 75)
						}
					}
				}
				.presentationDetents([.medium, .large])
				.presentationDragIndicator(.visible)
				// Add an ID to force refresh when openProduct changes
				.id(openProduct.selectedVariants.description)
			}
		}
	}
}

#Preview {
	@Previewable @State var viewModel = PointOfSaleViewModel(openProduct: ViewConfig.example())

	SelectVariants()
		.environment(viewModel)
}
