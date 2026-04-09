//
//  MedusaServerViewModel.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 08.03.25.
//

import Observation
import SwiftUI

enum MedusaServerConnectionError: Error {
    case invalidUrl
    case noResponse
    case notMedusa
    case authError
}

@Observable
class MedusaServerViewModel {
    var url: String = ""
    var email: String = ""
    var password: String = ""

    var loading = false
    var error: String?
    var success = false

    func userInput() {
        loading = false
        error = nil
        success = false
    }
}
