//
//  Networking.swift
//  xplanecon
//
//  Created by Anthony Pauriche on 09/02/2020.
//  Copyright © 2020 Anthony Pauriche. All rights reserved.
//

import Foundation
import Network

enum NetworkState {
    case subscribing(String),
    tryToListen,
    listening,
    error(String)
}

protocol NetworkDelegate: class {
    func network(network: Network, getData data: Data)
    func network(network: Network, stateChanged state: NetworkState)
}

class Network {
    weak var delegate: NetworkDelegate?
    
    var ip: String
    
    init(ip: String) {
        self.ip = ip
    }
    
    func createServer() {
        self.delegate?.network(network: self, stateChanged: .tryToListen)
        
        sleep(1)
        
        let server: NWListener?
        let params = NWParameters.udp
        let listenQueue = DispatchQueue(label: "listener")
        let connQueue = DispatchQueue(label: "connections")
        do {
            server = try NWListener(using: params, on: NWEndpoint.Port(integerLiteral: 55555))
            server?.newConnectionHandler = { con in
                con.start(queue: connQueue)
                con.stateUpdateHandler = { state in
                    switch state {
                    case .ready:
                        con.receiveMessage { (data: Data?, context: NWConnection.ContentContext?, isComplete: Bool, error: NWError?) in
                            if let error = error {
                                print(error)
                                return
                            }
                            
                            guard let data = data else { return }
                            
                            self.delegate?.network(network: self, getData: data)
                            
                            con.forceCancel()
                        }
                    default: break
                    }
                }
            }
            server?.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    self.delegate?.network(network: self, stateChanged: .listening)
                case .failed(let error):
                    self.delegate?.network(network: self, stateChanged: .error(error.debugDescription))
                    self.createServer()
                default:
                    break
                }
            }
            server?.start(queue: listenQueue)
        } catch {
            print("can't create listener")
        }
    }

    func subscribe() {
        self.delegate?.network(network: self, stateChanged: .subscribing(ip))
        
        let start = "RPOS\010\0"
        var data = Data()
        data.append(start.data(using: .utf8)!)
        
        let queue = DispatchQueue(label: "connection")
        let params = NWParameters.udp
        params.requiredLocalEndpoint = NWEndpoint.hostPort(host: NWEndpoint.Host("0.0.0.0"), port: NWEndpoint.Port(55555))
        let client = NWConnection(host: NWEndpoint.Host(ip), port: NWEndpoint.Port(integerLiteral: 49000), using: params)
        client.start(queue: queue)
        client.stateUpdateHandler = { state in
            switch state {
            case .ready:
                client.send(content: data, completion: .contentProcessed({ (error: NWError?) in
                    client.forceCancel()
                }))
            case .cancelled:
                self.createServer()
            case .failed(let error):
                self.delegate?.network(network: self, stateChanged: .error(error.debugDescription))
            default:
                break
            }
        }

    }
    
}
