//
//  PointOfSaleViewModel.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 14.03.25.
//

import Observation
import SwiftUI

struct SelectedVariant: Identifiable {
    var id: String

    var variant: Variants
    var amount: Int

    init(variant: Variants, amount: Int) {
        id = variant.id ?? UUID().uuidString
        self.variant = variant
        self.amount = amount
    }
}

struct ViewConfig: Identifiable, Equatable {
	static func == (lhs: ViewConfig, rhs: ViewConfig) -> Bool {
		return lhs.id == lhs.id
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

func viewConfigHasProduct(viewConfig: [ViewConfig], product: Product) -> Bool {
    for config in viewConfig {
        if config.product.id == product.id {
            return true
        }
    }
    return false
}

func getVariantById(viewConfig: ViewConfig, id: String) -> SelectedVariant? {
    return viewConfig.selectedVariants.first(where: { $0.variant.id == id })
}

struct SelectedSalesChannel: Identifiable {
    var id: String
    var salesChannel: SalesChannel
    var products: [ViewConfig]

    init(salesChannel: SalesChannel, products: [ViewConfig]) {
        id = salesChannel.id
        self.salesChannel = salesChannel
        self.products = products
    }
	
	static func examples() -> [SelectedSalesChannel] {
		return SalesChannel.examples().map { salesChannel in
			return SelectedSalesChannel(
				salesChannel: salesChannel,
				products: ViewConfig.examples()
			)
		}
	}
}

@Observable
class PointOfSaleViewModel {
    var numberOfTickets = 1

    let adaptiveColumn = [
		GridItem(.adaptive(minimum: 150), alignment: .top),
    ]

	var itemsInCart = false
    var selectedSalesChannels: [SelectedSalesChannel] = []

    var openProduct: ViewConfig?
    var salesChannelSelectOpen: Bool = false

	func addProductToCard(config: ViewConfig, variant: Variants) {
        // Get the product in all Sales-Channels, in case it is in multiple

        var updatedVariants: [SelectedVariant] = []

        // First, determine what the updated variants should be by looking at the first instance
        // of the product across all sales channels
        for salesChannel in selectedSalesChannels {
            if let product = salesChannel.products.first(where: { $0 == config }) {
                updatedVariants = product.selectedVariants

                // Update or add the variant
                if let existingVariantIndex = updatedVariants.firstIndex(where: { $0.variant == variant }) {
                    updatedVariants[existingVariantIndex].amount += 1
                } else {
                    updatedVariants.append(SelectedVariant(variant: variant, amount: 1))
                }

                break // Only update from the first instance found
            }
        }

        var updatedOpenProduct: ViewConfig?

        // Now apply these updated variants to all instances of the product across all sales channels
        for salesChannelIndex in 0 ..< selectedSalesChannels.count {
            if let productIndex = selectedSalesChannels[salesChannelIndex].products.firstIndex(where: { $0 == config }) {
                selectedSalesChannels[salesChannelIndex].products[productIndex].selectedVariants = updatedVariants

                // Save the updated product for refreshing UI
                updatedOpenProduct = selectedSalesChannels[salesChannelIndex].products[productIndex]
            }
        }

		if openProduct != nil {
			// Update openProduct to ensure UI refreshes
			if let updatedProduct = updatedOpenProduct {
				openProduct = updatedProduct
			}
		}
		
		withAnimation {
			itemsInCart = true
		}
    }

    // Helper method to get variant amount directly from selectedSalesChannels
	func getVariantAmount(config: ViewConfig, variant: Variants) -> Int {
        // Since all instances are synchronized, we only need to check the first instance
        for salesChannel in selectedSalesChannels {
            if let product = salesChannel.products.first(where: { $0 == config }),
               let variant = product.selectedVariants.first(where: { $0.variant == variant })
            {
                // Return the amount from the first instance found
                return variant.amount
            }
        }

        return 0
    }

    func toggleSalesChannel(salesChannel: SalesChannel, products: [Product]) {
        if selectedSalesChannels.contains(where: { $0.salesChannel == salesChannel }) {
            selectedSalesChannels.removeAll(where: { $0.salesChannel == salesChannel })
        } else {
            selectedSalesChannels.append(SelectedSalesChannel(salesChannel: salesChannel, products: products.map { product in
                ViewConfig(product: product, selectedVariants: [])
            }))
        }
    }

    init() {}

	init(selectedSalesChannels: [SelectedSalesChannel]) {
		self.selectedSalesChannels = selectedSalesChannels
    }
	
	init(openProduct: ViewConfig?) {
		self.openProduct = openProduct
	}

	func removeProductFromCard(config: ViewConfig, variant: Variants) {
        var updatedVariants: [SelectedVariant] = []
        var shouldRemove = false

        // First, determine what the updated variants should be by looking at the first instance
        // of the product across all sales channels
        for salesChannel in selectedSalesChannels {
            if let product = salesChannel.products.first(where: { $0 == config }) {
                updatedVariants = product.selectedVariants

                // Update or remove the variant
                if let existingVariantIndex = updatedVariants.firstIndex(where: { $0.variant == variant }) {
                    if updatedVariants[existingVariantIndex].amount > 1 {
                        updatedVariants[existingVariantIndex].amount -= 1
                    } else {
                        // Remove the variant if amount reaches 0
                        updatedVariants.remove(at: existingVariantIndex)
                    }
                }

                break // Only update from the first instance found
            }
        }

        var updatedOpenProduct: ViewConfig?

        // Now apply these updated variants to all instances of the product across all sales channels
        for salesChannelIndex in 0 ..< selectedSalesChannels.count {
            if let productIndex = selectedSalesChannels[salesChannelIndex].products.firstIndex(where: { $0 == config }) {
                selectedSalesChannels[salesChannelIndex].products[productIndex].selectedVariants = updatedVariants

                // Save the updated product for refreshing UI
                updatedOpenProduct = selectedSalesChannels[salesChannelIndex].products[productIndex]
            }
        }

        if openProduct != nil {
            // Update openProduct to ensure UI refreshes
            if let updatedProduct = updatedOpenProduct {
                openProduct = updatedProduct
            }
        }
        
        // Check if cart is now empty
        let cartHasItems = selectedSalesChannels.contains { channel in
            channel.products.contains { product in
                !product.selectedVariants.isEmpty
            }
        }
        
        withAnimation {
            itemsInCart = cartHasItems
        }
    }
}
