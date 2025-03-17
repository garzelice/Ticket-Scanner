//
//  SelectedVariant.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 17.03.25.
//


import Observation
import SwiftUI
import CoreHaptics

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