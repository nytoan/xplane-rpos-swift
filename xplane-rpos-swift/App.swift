//
//  App.swift
//  xplanecon
//
//  Created by Anthony Pauriche on 09/02/2020.
//  Copyright © 2020 Anthony Pauriche. All rights reserved.
//

import Foundation

class App {
    static let app: App = App()
    static func start() {
        _ = App.app
    }
    
    var ui: UI = UI()
    var network: Network
    
    init() {
        var ip: String = "255.255.255.255"
        if CommandLine.arguments.count > 1 {
            ip = CommandLine.arguments[1]
        }
        
        network = Network(ip: ip)
        network.delegate = self
        network.subscribe()
        
        RunLoop.main.run()
    }
    
}

extension App: NetworkDelegate {
    func network(network: Network, getData data: Data) {
        ui.showInformations(informations: Parser.getInformations(data: data))
    }
    
    func network(network: Network, stateChanged state: NetworkState) {
        switch state {
        case .subscribing(let ip):
            ui.showConnectionState(message: "Try to connect to X-Plane at \(ip)...")
        case .tryToListen:
            ui.showConnectionState(message: "Try to listening to X-Plane data...")
        case .listening:
            ui.showConnectionState(message: "Listening to X-Plane")
        case .error(let message):
            ui.showConnectionState(message: message)
        }
    }
    
}
