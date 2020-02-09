//
//  UI.swift
//  xplanecon
//
//  Created by Anthony Pauriche on 09/02/2020.
//  Copyright © 2020 Anthony Pauriche. All rights reserved.
//

import Foundation

class UI {
    var first: Bool = true
    
    func showConnectionState(message: String) {
        print(message)
    }

    func showInformations(informations: [String]) {
        if !first {
            print("\u{001B}[14A")
        }
        first = false
        
        informations.forEach {
            print($0)
        }
    }
    
}
