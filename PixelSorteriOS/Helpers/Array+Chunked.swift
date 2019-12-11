//
//  Array+Chunked.swift
//  PixelSorteriOS
//
//  Created by Spencer Curtis on 12/11/19.
//  Copyright © 2019 Spencer Curtis. All rights reserved.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
