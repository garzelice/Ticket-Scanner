//
//  PointOfSaleViewModel.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 14.03.25.
//

import CoreHaptics
import Observation
import SwiftUI

@Observable
class PointOfSaleViewModel {
	let adaptiveColumn = [
		GridItem(.adaptive(minimum: 150), alignment: .top)
	]

	var itemsInCart = false
	var products: [ViewConfig] = []

	var openProduct: ViewConfig?

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
		let event = CHHapticEvent(
			eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
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

	func addProductToCard(config: ViewConfig, variant: Variants) {
		var updatedVariants: [SelectedVariant] = []

		// Find the product and update its variants
		if let product = products.first(where: { $0 == config }) {
			updatedVariants = product.selectedVariants

			// Update or add the variant
			if let existingVariantIndex = updatedVariants.firstIndex(where: {
				$0.variant == variant
			}) {
				updatedVariants[existingVariantIndex].amount += 1
			} else {
				updatedVariants.append(SelectedVariant(variant: variant, amount: 1))
			}
		}

		var updatedOpenProduct: ViewConfig?

		// Apply the updated variants to the product
		if let productIndex = products.firstIndex(where: { $0 == config }) {
			products[productIndex].selectedVariants = updatedVariants

			// Save the updated product for refreshing UI
			updatedOpenProduct = products[productIndex]
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

	// Helper method to get variant amount for a product
	func getVariantAmount(config: ViewConfig, variant: Variants) -> Int {
		if let product = products.first(where: { $0 == config }),
			let selectedVariant = product.selectedVariants.first(where: { $0.variant == variant })
		{
			return selectedVariant.amount
		}

		return 0
	}

	init() {}

	init(openProduct: ViewConfig?) {
		self.openProduct = openProduct
	}

	func removeProductFromCard(config: ViewConfig, variant: Variants) {
		var updatedVariants: [SelectedVariant] = []

		// Check if cart has items for haptic feedback
		let cartHasItems = products.contains { product in
			!product.selectedVariants.isEmpty
		}

		if cartHasItems {
			complexSuccess()
		}

		// Find the product and update its variants
		if let product = products.first(where: { $0 == config }) {
			updatedVariants = product.selectedVariants

			// Update or remove the variant
			if let existingVariantIndex = updatedVariants.firstIndex(where: {
				$0.variant == variant
			}) {
				if updatedVariants[existingVariantIndex].amount > 1 {
					updatedVariants[existingVariantIndex].amount -= 1
				} else {
					// Remove the variant if amount reaches 0
					updatedVariants.remove(at: existingVariantIndex)
				}
			}
		}

		var updatedOpenProduct: ViewConfig?

		if let productIndex = products.firstIndex(where: { $0 == config }) {
			products[productIndex].selectedVariants = updatedVariants

			// Save the updated product for refreshing UI
			updatedOpenProduct = products[productIndex]
		}

		if openProduct != nil {
			// Update openProduct to ensure UI refreshes
			if let updatedProduct = updatedOpenProduct {
				openProduct = updatedProduct
			}
		}

		// Check if cart is now empty
		let updatedCartHasItems = products.contains { product in
			!product.selectedVariants.isEmpty
		}

		withAnimation {
			itemsInCart = updatedCartHasItems
		}
	}

	// Get the current variants for a product
	func getProductVariants(config: ViewConfig) -> [SelectedVariant] {
		if let product = products.first(where: { $0.product.id == config.product.id }) {
			return product.selectedVariants
		}

		return []
	}
}
