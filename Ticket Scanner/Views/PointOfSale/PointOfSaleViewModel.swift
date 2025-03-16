//
//  PointOfSaleViewModel.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 14.03.25.
//

import SwiftUI
import Observation

struct SelectedVariant {
	var variant: String
	var amount: Int
}

struct ViewConfig: Identifiable {
	var id: String
	var product: Products
	var selectedVariants: [SelectedVariant]
	
	init(product: Products, selectedVariants: [SelectedVariant]) {
		self.id = product.id
		self.product = product
		self.selectedVariants = selectedVariants
	}
}

func viewConfigHasProduct(viewConfig: [ViewConfig], product: Products) -> Bool {
	for config in viewConfig {
		if config.product.id == product.id {
			return true
		}
	}
	return false
}

func getVariantById(viewConfig: ViewConfig, id: String) -> SelectedVariant? {
	return viewConfig.selectedVariants.first(where: { $0.variant == id })
}

struct SelectedSalesChannel: Identifiable {
	var id: String
	var salesChannel: Sales_channels
	var products: [ViewConfig]
	
	init(salesChannel: Sales_channels, products: [ViewConfig]) {
		self.id = salesChannel.id
		self.salesChannel = salesChannel
		self.products = products
	}
}

@Observable
class PointOfSaleViewModel {
	var numberOfTickets = 1
	
	let adaptiveColumn = [
		GridItem(.adaptive(minimum: 150))
	]
	
	//	@State var basket = nil
	var viewConfig: [ViewConfig] = []
	
	var selectedSalesChannels: [SelectedSalesChannel] = []
	
	var openProduct: ViewConfig? = nil
	var salesChannelSelectOpen: Bool = false
	
	func addProductToCard(variantId: String) -> Void {
		guard let productIndex = self.viewConfig.firstIndex(where: { $0.product.id == self.openProduct?.id }) else {
			print("Couldnt’t get product")
			return
		}
		
		if let existingVariantIndex = self.viewConfig[productIndex].selectedVariants.firstIndex(where: { $0.variant == variantId }) {
			self.viewConfig[productIndex].selectedVariants[existingVariantIndex].amount += 1
		} else {
			self.viewConfig[productIndex].selectedVariants.append(SelectedVariant(variant: variantId, amount: 1))
		}
		
		// Update openProduct to ensure UI refreshes
		self.openProduct = self.viewConfig[productIndex]
	}
	
	// Helper method to get variant amount directly from viewConfig
	func getVariantAmount(variantId: String) -> Int {
		guard let productId = openProduct?.id,
			  let productIndex = viewConfig.firstIndex(where: { $0.id == productId }),
			  let variantIndex = viewConfig[productIndex].selectedVariants.firstIndex(where: { $0.variant == variantId }) else {
			return 0
		}
		
		return viewConfig[productIndex].selectedVariants[variantIndex].amount
	}
	
	func toggleSalesChannel(salesChannel: Sales_channels, products: [Products]) {
		if selectedSalesChannels.contains(where: {$0.salesChannel == salesChannel}) {
			selectedSalesChannels.removeAll(where: {$0.salesChannel == salesChannel})
		} else {
			selectedSalesChannels.append(SelectedSalesChannel(salesChannel: salesChannel, products: products.map { product in
				return ViewConfig(product: product, selectedVariants: [])
			}))
		}
	}
	
	init() {
		
	}
	
	init(viewConfig: [ViewConfig], openProduct: ViewConfig?) {
		self.viewConfig = viewConfig
		self.openProduct = openProduct
	}
}
