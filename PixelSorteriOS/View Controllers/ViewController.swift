//
//  ViewController.swift
//  PixelSorteriOS
//
//  Created by Spencer Curtis on 5/10/18.
//  Copyright © 2018 Spencer Curtis. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var processedImageView: UIImageView!
    @IBOutlet weak var saveImageButton: UIButton!
    @IBOutlet weak var processFullImageButton: UIButton!
    @IBOutlet weak var processSmallerImageButton: UIButton!
    @IBOutlet weak var photoLibraryButton: UIButton!
    
    var shouldProcessFullImage = true
    
    let opQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        queue.maxConcurrentOperationCount = 4
        return queue
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        saveImageButton.layer.cornerRadius = 8
        processFullImageButton.layer.cornerRadius = 8
        processSmallerImageButton.layer.cornerRadius = 8
        photoLibraryButton.layer.cornerRadius = 8
    }
    
    // MARK: - Actions
    
    @IBAction func processFullImage(_ sender: Any) {
        shouldProcessFullImage = true
        presentImagePicker()
    }
    
    @IBAction func processSmallerImage(_ sender: Any) {
        shouldProcessFullImage = false
        presentImagePicker()
    }
    
    @IBAction func saveImageButtonTapped(_ sender: Any) {
        
        guard let image = processedImageView.image else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    // MARK: - Private
    
    private func presentImagePicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        
        let picker = UIImagePickerController()
        
        picker.sourceType = .photoLibrary
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
    }
    
    
    
    private func process(image: UIImage) {
        
        UIGraphicsBeginImageContext(image.size)
        
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        guard let context = UIGraphicsGetCurrentContext() else { print("No graphics context"); return }
        
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        
        guard let data = context.data?.assumingMemoryBound(to: UInt8.self) else { print("No data"); return }
        
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
        
        var pixelArrays: [[Pixel]] = pixels.chunked(into: pixels.count / 4)
        
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
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        DispatchQueue.main.async {
            
            UIView.transition(with: self.processedImageView, duration: 1, options: .transitionCrossDissolve, animations: {
                self.processedImageView.image = newImage
            })
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) {
            
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            
            self.processedImageView.image = image
            
            guard self.shouldProcessFullImage else {
                
                if let scaledImage = image.imageByScaling(toSize: image.size.scaledSize(maxLargerDimension: 1300)) {
                    self.process(image: scaledImage)
                }
                
                return
            }
            
            self.process(image: image)
        }
    }
}
