//
//  SelectedSalesChannel.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 17.03.25.
//


import Observation
import SwiftUI
import CoreHaptics

struct SelectedSalesChannel: Identifiable, Equatable {
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