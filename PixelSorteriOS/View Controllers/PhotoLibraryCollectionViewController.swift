//
//  PhotoLibraryCollectionViewController.swift
//  PixelSorteriOS
//
//  Created by Spencer Curtis on 6/13/19.
//  Copyright © 2019 Spencer Curtis. All rights reserved.
//

import UIKit
import Photos

// WARNING: This view controller is not functional yet.

class PhotoLibraryCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var assets: PHFetchResult<PHAsset>!
    
    var imagesShouldBeSquare = false {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchAssets()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchAssets()
        collectionView.reloadData()
    }
    
    @IBAction func changeLayout(_ sender: Any) {
        imagesShouldBeSquare = !imagesShouldBeSquare
    }
    
    func fetchAssets() {
        assets = PHAsset.fetchAssets(with: .image, options: nil)
    }
}

extension PhotoLibraryCollectionViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoAssetCollectionViewCell ?? PhotoAssetCollectionViewCell()
    
        cell.asset = assets[indexPath.row]
    
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard !imagesShouldBeSquare else {
            return CGSize(width: 80, height: 80)
        }
        
        let asset = assets[indexPath.row]

        return CGSize(width: asset.pixelWidth, height: asset.pixelHeight).scaledSize(maxLargerDimension: 100)
    }
}
