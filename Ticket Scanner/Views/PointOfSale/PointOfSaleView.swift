//
//  PointOfSaleView.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 08.03.25.
//

import SwiftUI

struct LargeButton: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding()
			.background(.blue.opacity(0.15))
			.foregroundStyle(.blue)
			.clipShape(.buttonBorder)
			.opacity(configuration.isPressed ? 0.4 : 1)
	}
}

struct PointOfSale: View {
	@Environment(Medusa.self) private var medusa
	@Environment(Auth.self) private var auth
	@State var viewModel = PointOfSaleViewModel()

	var body: some View {
		NavigationStack {
			ZStack(alignment: .bottom) {
				ScrollView {
					VStack {
						if !viewModel.products.isEmpty {
							LazyVGrid(
								columns: viewModel.adaptiveColumn, alignment: .leading, spacing: 20
							) {
								ProductsView(products: viewModel.products)
							}
						} else {
							Text("No products available")
								.foregroundStyle(.secondary)
								.padding()
						}
					}
					.padding()
				}
				.refreshable {
					await refreshProducts()
				}
				if viewModel.itemsInCart {
					VStack(alignment: .leading) {
						Text("Payment Method")
							.font(.title2)
						HStack {
							Button {

							} label: {
								Label("Cash", systemImage: "banknote")
									.frame(maxWidth: .infinity)
							}
							.buttonStyle(LargeButton())
							Button {

							} label: {
								Label("Creditcard", systemImage: "banknote")
									.frame(maxWidth: .infinity)
							}
							.buttonStyle(LargeButton())
						}
					}
					.padding()
					.background(Color(UIColor.systemBackground))
					.frame(maxWidth: .infinity)
					.clipShape(
						UnevenRoundedRectangle(cornerRadii: .init(topLeading: 10, topTrailing: 10))
					)
					.transition(.move(edge: .bottom))
				}
			}
			.sheet(item: $viewModel.openProduct) { _ in
				SelectVariants()
					.environment(viewModel)
			}

			.navigationTitle("Offline Shop")
			.onAppear {
				Task {
					await refreshProducts()
				}
				viewModel.prepareHaptics()
			}

			.background(Color(UIColor.secondarySystemBackground))
			.toolbarBackground(Color(UIColor.systemBackground), for: .tabBar)
			.toolbarBackground(.visible, for: .tabBar)
			.toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
			.toolbarBackground(.visible, for: .navigationBar)
		}
	}

	private func refreshProducts() async {
		await medusa.getSalesChannels(auth: auth)
		if let selectedSalesChannel = medusa.selectedSalesChannel {
			medusa.getProducts(auth: auth, salesChannelId: selectedSalesChannel.id)
			// Convert products to ViewConfig for the ViewModel
			viewModel.products = medusa.products.map { product in
				ViewConfig(product: product, selectedVariants: [])
			}
		}
	}
}
