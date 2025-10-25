//
//  PointOfSaleViewModel.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 14.03.25.
//

import Observation
import SwiftUI
import CoreHaptics


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


@Observable
class PointOfSaleViewModel {
    var numberOfTickets = 1

    let adaptiveColumn = [
		GridItem(.adaptive(minimum: 150), alignment: .top),
    ]

	var itemsInCart = false
    var selectedSalesChannel: SelectedSalesChannel?

    var openProduct: ViewConfig?
    var salesChannelSelectOpen: Bool = false
	
	private var engine: CHHapticEngine?
	
	func prepareHaptics() {
		guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

		do {
			engine = try CHHapticEngine()
			try engine?.start()
		} catch {
			print("There was an error creating the engine: \(error.localizedDescription)")
		}
	}
	
	func complexSuccess() {
		// make sure that the device supports haptics
		guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
		var events = [CHHapticEvent]()

		// create one intense, sharp tap
		let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
		let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
		let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
		events.append(event)

		// convert those events into a pattern and play it immediately
		do {
			let pattern = try CHHapticPattern(events: events, parameters: [])
			let player = try engine?.makePlayer(with: pattern)
			try player?.start(atTime: 0)
		} catch {
			print("Failed to play pattern: \(error.localizedDescription).")
		}
	}

	func addProductToCart(config: ViewConfig, variant: Variants) {
        // Get the product in all Sales-Channels, in case it is in multiple

        var updatedVariants: [SelectedVariant] = []
		
		guard var salesChannel = selectedSalesChannel else {
			return print("sales channel not found")
		}

        // First, determine what the updated variants should be by looking at the first instance
        // of the product across all sales channels
		if let product = salesChannel.products.first(where: { $0 == config }) {
			updatedVariants = product.selectedVariants

			// Update or add the variant
			if let existingVariantIndex = updatedVariants.firstIndex(where: { $0.variant == variant }) {
				updatedVariants[existingVariantIndex].amount += 1
			} else {
				updatedVariants.append(SelectedVariant(variant: variant, amount: 1))
			}
		}

        var updatedOpenProduct: ViewConfig?

        // Now apply these updated variants to all instances of the product across all sales channels
		if let productIndex = salesChannel.products.firstIndex(where: { $0 == config }) {
			salesChannel.products[productIndex].selectedVariants = updatedVariants

			// Save the updated product for refreshing UI
			updatedOpenProduct = salesChannel.products[productIndex]
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

		complexSuccess()
    }

    // Helper method to get variant amount directly from selectedSalesChannels
	func getVariantAmount(config: ViewConfig, variant: Variants) -> Int {
        // Since all instances are synchronized, we only need to check the first instance
		if let salesChannel = selectedSalesChannel {
			if let product = salesChannel.products.first(where: { $0 == config }),
			   let variant = product.selectedVariants.first(where: { $0.variant == variant })
			{
				// Return the amount from the first instance found
				return variant.amount
			}
		}

        return 0
    }

    init() {}
	
	init(openProduct: ViewConfig?) {
		self.openProduct = openProduct
	}

	func removeProductFromCart(config: ViewConfig, variant: Variants) {
		guard var channel = selectedSalesChannel else {
			return print("No Sales Channel")
		}
		
        var updatedVariants: [SelectedVariant] = []
        
		// Check if cart is now empty
		var cartHasItems = channel.products.contains { product in
			!product.selectedVariants.isEmpty
	   }
		
		if cartHasItems {
			complexSuccess()
		}

        // First, determine what the updated variants should be by looking at the first instance
        // of the product across all sales channels
		if let product = channel.products.first(where: { $0 == config }) {
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
		}

        var updatedOpenProduct: ViewConfig?
		
		if let productIndex = channel.products.firstIndex(where: { $0 == config }) {
			channel.products[productIndex].selectedVariants = updatedVariants
			
			// Save the updated product for refreshing UI
			updatedOpenProduct = channel.products[productIndex]
		}

        if openProduct != nil {
            // Update openProduct to ensure UI refreshes
            if let updatedProduct = updatedOpenProduct {
                openProduct = updatedProduct
            }
        }
        
        // Check if cart is now empty
		cartHasItems = channel.products.contains { product in
			!product.selectedVariants.isEmpty
		}
		
        withAnimation {
            itemsInCart = cartHasItems
        }
    }

    // Add a method to get the current variants for a product directly from the model
    func getProductVariants(config: ViewConfig) -> [SelectedVariant] {
        
		if let salesChannel = selectedSalesChannel, let product = salesChannel.products.first(where: { $0.product.id == config.product.id }) {
			return product.selectedVariants
		}
        
        return []
    }
}
