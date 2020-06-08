//
//  PixelSorter.swift
//  PixelSorteriOS
//
//  Created by Spencer Curtis on 6/7/20.
//  Copyright © 2020 Spencer Curtis. All rights reserved.
//

import UIKit

class PixelSorter {
    
    static private var opQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    static func process(image: UIImage, with maxOperationCount: Int = 4) -> UIImage? {
        
        opQueue.maxConcurrentOperationCount = maxOperationCount
        
        UIGraphicsBeginImageContext(image.size)
        
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        guard let context = UIGraphicsGetCurrentContext(),
            let data = context.data?.assumingMemoryBound(to: UInt8.self) else {
                NSLog("Current context not available")
                return nil
        }
        
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        
        var pixels: [Pixel] = []
        
        for x in 0..<width {
            for y in 0..<height {
                let pixelAddress = context.bytesPerRow * y + (4 * x)
                let blue = data[pixelAddress]
                let green = data[pixelAddress + 1]
                let red = data[pixelAddress + 2]
                let alpha = data[pixelAddress + 3]
                
                let total = Int(red) + Int(green) + Int(blue) + Int(alpha)
                
                let pixel = Pixel(blue: blue, green: green, red: red, alpha: alpha, total: total)
                
                pixels.append(pixel)
            }
        }
            
        var pixelArrays: [[Pixel]] = pixels.chunked(into: pixels.count / maxOperationCount)
        
        for i in 0..<pixelArrays.count {
            opQueue.addOperation {
                pixelArrays[i].sort(by: { $0.total > $1.total })
            }
        }
        
        opQueue.waitUntilAllOperationsAreFinished()
        
        pixels = pixelArrays.flatMap({$0})
        pixels.sort(by: { $0.total > $1.total })
                
        var index = 0
        
        for pixel in pixels {
            data[index] = pixel.blue
            data[index + 1] = pixel.green
            data[index + 2] = pixel.red
            data[index + 3] = pixel.alpha
            index += 4
        }
        
        let sortedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return sortedImage
    }
}
