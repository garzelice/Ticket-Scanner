//
//  NetworkMonitor.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 12.08.25.
//

import Foundation
import Network
import Observation

@Observable
final class NetworkMonitor: @unchecked Sendable {
    var isOnline: Bool = true {
        didSet {
            if isOnline != oldValue {
                NotificationCenter.default.post(name: .networkStatusChanged, object: nil, userInfo: ["isOnline": isOnline])
            }
        }
    }

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")

    init() {
        self.monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            let isOnline = path.status == .satisfied
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .networkStatusChanged, object: nil, userInfo: ["isOnline": isOnline])
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}