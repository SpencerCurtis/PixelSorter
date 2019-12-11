//
//  PhotoAssetCollectionViewCell.swift
//  PixelSorteriOS
//
//  Created by Spencer Curtis on 6/13/19.
//  Copyright © 2019 Spencer Curtis. All rights reserved.
//

import UIKit
import Photos

class PhotoAssetCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    override func awakeFromNib() {
        imageView.layer.cornerRadius = 6
    }
    
    var cellSize: CGSize = .zero
    var asset: PHAsset? {
        didSet {
            
            guard let asset = asset else { return }
            
            cellSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight).scaledSize(maxLargerDimension: 100)
            
            loadAsset()
        }
    }
    
    private func loadAsset() {
        
        guard let asset = asset else { return }
        
        PHImageManager.default().requestImage(for: asset, targetSize: cellSize, contentMode: .aspectFill, options: nil) { (image, statusDictionary) in
            self.imageView.image = image
        }
    }
}
