//
//  Pixel.swift
//  PixelSorteriOS
//
//  Created by Spencer Curtis on 12/11/19.
//  Copyright © 2019 Spencer Curtis. All rights reserved.
//

import Foundation

struct Pixel {
    let blue: UInt8
    let green: UInt8
    let red: UInt8
    let alpha: UInt8
    let total: Int
    
    var values: [UInt8] {
        return [alpha, red, green, blue]
    }
}
