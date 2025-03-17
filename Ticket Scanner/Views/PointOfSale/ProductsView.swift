//
//  ProductsView.swift
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
			switch config.product.cardSize {
			case .small:
				SmallProductView(config: config)
			case .regular:
				ProductView(config: config)
			}
        }
    }
}

#Preview {
    @Previewable @State var viewModel = PointOfSaleViewModel()

	ProductsView(products: ViewConfig.examples())
        .environment(viewModel)
}
