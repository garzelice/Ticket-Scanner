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
    @State var viewModel = PointOfSaleViewModel()

    var body: some View {
        NavigationStack {
			ZStack(alignment: .bottom) {
				ScrollView {
					VStack {
						SalesChannelSection()
							.environment(viewModel)
						
						AddSalesChannelButton()
							.environment(viewModel)
					}
					.padding()
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
					.clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 10, topTrailing: 10)))
					.transition(.move(edge: .bottom))
				}
			}
            .sheet(isPresented: $viewModel.salesChannelSelectOpen) {
                SalesChannelSelectionSheet(isPresented: $viewModel.salesChannelSelectOpen)
                    .environment(viewModel)
            }
            .sheet(item: $viewModel.openProduct) { _ in
                SelectVariants()
                    .environment(viewModel)
            }
            
            .navigationTitle("Point of Sale")
            .onAppear {
                medusa.getProducts()
                medusa.getSalesChannels()
            }
			.background(Color(UIColor.secondarySystemBackground))
			.toolbarBackground(Color(UIColor.systemBackground), for: .tabBar)
			.toolbarBackground(.visible, for: .tabBar)
			.toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
			.toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    @Previewable @State var medusa = Medusa(user: User(), server: Server(), products: Product.examples())
    PointOfSale()
        .environment(medusa)
}
