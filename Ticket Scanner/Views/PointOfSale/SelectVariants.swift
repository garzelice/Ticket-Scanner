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
        return viewModel.getVariantAmount(variant: variant)
    }

    var body: some View {
        if let variants = viewModel.openProduct?.product.variants {
            Form {
                ForEach(variants) { variant in
                    HStack {
                        Text(variant.title ?? "No Title")
                        Spacer()
                        Text("\(getCurrent(variant: variant))")
                        Stepper {} onIncrement: {
                            viewModel.addProductToCard(variant: variant)
                            if let variantId = variant.id {}
                        } onDecrement: {
                            if let variantId = variant.id {
                                //								viewModel.addProductToCard(variantId: variantId)
                            }
                        }
                        .frame(width: 75)
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            // Add an ID to force refresh when openProduct changes
            .id(viewModel.openProduct?.selectedVariants.description)
        }
    }
}

#Preview {
	@Previewable @State var viewModel = PointOfSaleViewModel(openProduct: ViewConfig.example())

    SelectVariants()
        .environment(viewModel)
}
