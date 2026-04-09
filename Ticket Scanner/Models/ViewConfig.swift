//
//  ViewConfig.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 17.03.25.
//


import Observation
import SwiftUI
import CoreHaptics

struct ViewConfig: Identifiable, Equatable {
	static func == (lhs: ViewConfig, rhs: ViewConfig) -> Bool {
		return lhs.id == rhs.id
	}
	
    var id: String
    var product: Product
    var selectedVariants: [SelectedVariant]

    init(product: Product, selectedVariants: [SelectedVariant]) {
        id = product.id
        self.product = product
        self.selectedVariants = selectedVariants
    }
	
	static func example() -> ViewConfig {
		return ViewConfig(product: Product.example(), selectedVariants: [])
	}
	
	static func examples() -> [ViewConfig] {
		return Product.examples().map { product in
			ViewConfig(product: product, selectedVariants: [])
		}
	}
}