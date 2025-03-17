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
            ScrollView {
                SalesChannelSection()
                    .environment(viewModel)
                VStack {
                    Text("Add Sales Channel")
                        .font(.caption2)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.gray)
                        .padding()
                    Button {
                        viewModel.salesChannelSelectOpen = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(LargeButton())
                    Spacer()
                }
            }
            .sheet(isPresented: $viewModel.salesChannelSelectOpen) {
                NavigationView {
                    List(medusa.salesChannels) { salesChannel in
                        Label(salesChannel.name ?? "No Sales Channel Name", systemImage: viewModel.selectedSalesChannels.contains(where: { $0.salesChannel == salesChannel }) ? "checkmark.circle.fill" : "circle")
                            .onTapGesture {
                                viewModel.toggleSalesChannel(salesChannel: salesChannel, products: medusa.products.filter { product in
                                    guard let productSalesChannels = product.sales_channels else {
                                        return false
                                    }
                                    return productSalesChannels.contains(where: { $0 == salesChannel })
                                })
                            }
                    }
                    .navigationTitle("Select Sales Channel")
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(item: $viewModel.openProduct, content: { _ in
                SelectVariants()
                    .environment(viewModel)
            })
            .padding()
            .navigationTitle("Point of Sale")
            .onAppear {
                medusa.getProducts()
                medusa.getSalesChannels()
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

#Preview {
    @Previewable @State var medusa = Medusa(user: User(), server: Server(), products: MockData().products)
    PointOfSale()
        .environment(medusa)
}
