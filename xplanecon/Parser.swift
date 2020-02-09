//
//  Parser.swift
//  xplanecon
//
//  Created by Anthony Pauriche on 09/02/2020.
//  Copyright © 2020 Anthony Pauriche. All rights reserved.
//

// Structure of the data sended by X-Plane
//
//  69 bytes
//
//  lon, lat and elevation above sea are doubles (8 bytes), the rest are floats (4 bytes)
//
//      RPOS\0              lon               lat
//  o------------o o---------------------o o-------
//  52 50 4f 53 34 b1 48 fa 25 1a ca 08 40 23 13 d2
//
//       lat         elevation above sea        elevation above terrain
//  -------------o o---------------------o o-------
//  0f b2 48 49 40 00 00 ee 05 45 09 47 40 50 e1 a6
//
//        pitch      heading       roll      X speed
//  -o o---------o o---------o o---------o o-------
//  3d 1e e5 86 3f a4 31 7d 43 5b bc 8b be db 10 90
//
//       Y speed     Z speed    roll rate   pitch rate
//  -o o---------o o---------o o---------o o-------
//  b9 6f ec 11 b9 10 64 b2 b9 82 8e 87 39 a9 f1 47
//
//       yaw rate
//  -o o---------o
//  b8 89 12 dd 37

import Foundation

struct Parser {
    private static let infos = [
        ["lon:", "%.6f", ""],
        ["lat:", "%.6f", ""],
        ["elevation above sea:", "%.2f", "m"],
        ["elevation above terrain:", "%.2f", "m"],
        ["pitch:", "%.2f", "°"],
        ["heading:", "%.2f", "°"],
        ["roll:", "%.2f", "°"],
        ["X speed:", "%.2f", "m/s"],
        ["Y speed:", "%.2f", "m/s"],
        ["Z speed:", "%.2f", "m/s"],
        ["roll rate:", "%.2f", "rad/s"],
        ["pitch rate:", "%.2f", "rad/s"],
        ["yaw rate:", "%.2f", "rad/s"]
    ]
    
    private static func getValue<T: FloatingPoint>(type: T.Type, bytes: ArraySlice<UInt8>, range: Range<Int>) -> T {
        var v = T.init(0)
        memcpy(&v, Array<UInt8>(bytes[range]), range.upperBound - range.lowerBound)
        return v
    }

    static func getInformations(data: Data) -> [String] {
        var informations: [String] = []
        
        let bytes = ArraySlice<UInt8>([UInt8](data)[5...])
        var c = 0
        // for each 13 values
        for i in 0...12 {
            // the first three are double (8 bytes) the others are float (4 bytes)
            let size = i < 3 ? 8 : 4
            // get the range of the bytes corresponding to the value
            let range = c..<c + size
            // increment the cursor position in the bytes
            c += size
            
            var value: Float = 0
            if i < 3 {
                value = Float(getValue(type: Double.self, bytes: bytes, range: range))
            } else {
                value = getValue(type: Float.self, bytes: bytes, range: range)
            }
            informations.append("\(infos[i][0]) \(String(format: infos[i][1], value)) \(infos[i][2])")
        }
        
        return informations
    }
}
