//
//  CGSize+AspectRatio.swift
//  PixelSorteriOS
//
//  Created by Spencer Curtis on 6/13/19.
//  Copyright © 2019 Spencer Curtis. All rights reserved.
//

import UIKit

extension CGSize {
    var aspectRatio: (aspectRatio: CGFloat, largerDimension: Dimension) {
        let larger = max(self.width, self.height)
        
        let isHeightLarger = larger == self.height
        
        let aspectRatio: CGFloat
        
        if isHeightLarger {
            aspectRatio = larger / width
        } else {
            aspectRatio = larger / height
        }
        
        return (aspectRatio, isHeightLarger ? .height : .width)
    }
    
    func scaledSize(maxLargerDimension: CGFloat) -> CGSize {
        let aspectRatio = self.aspectRatio
        
        let largerMax: CGFloat = maxLargerDimension
        
        let newSize: CGSize
        
        if aspectRatio.largerDimension == .height {
            newSize = CGSize(width: largerMax / aspectRatio.aspectRatio, height: largerMax)
        } else {
            newSize = CGSize(width: largerMax, height: largerMax / aspectRatio.aspectRatio)
        }
        
        return newSize
    }
}

enum Dimension {
    case width
    case height
}
extension UIImage {
    func upOrientationImage() -> UIImage? {
        switch imageOrientation {
        case .up:
            return self
        default:
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            draw(in: CGRect(origin: .zero, size: size))
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return result
        }
    }
}
