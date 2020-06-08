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
    
    @IBOutlet weak var indicatorBackgroundView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var processedImageView: UIImageView!
    @IBOutlet weak var saveImageButton: UIButton!
    @IBOutlet weak var processFullImageButton: UIButton!
    @IBOutlet weak var processSmallerImageButton: UIButton!
    @IBOutlet weak var photoLibraryButton: UIButton!
    @IBOutlet var bottomButtons: [UIButton]!
    
    var shouldProcessFullImage = true
    
    /// The number of operations that should be run to sort a split array of pixels. 4 seems to be the most efficient
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoLibraryButton.isHidden = true
        indicatorBackgroundView.isHidden = true
        saveImageButton.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bottomButtons.forEach({
            $0.layer.cornerRadius = 8
            $0.layer.borderColor = UIColor.lightGray.cgColor
            $0.layer.borderWidth = 1
        })
        
        indicatorBackgroundView.layer.cornerRadius = 8
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
    
    private func startIndicator() {
        indicatorBackgroundView.isHidden = false
        activityIndicator.startAnimating()
    }
    private func stopIndicator() {
        indicatorBackgroundView.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    
    private func process(image: UIImage) {
        let sortedImage = PixelSorter.process(image: image, with: 4)
        DispatchQueue.main.async {
            self.stopIndicator()
            self.saveImageButton.alpha = 1
            
            UIView.transition(with: self.processedImageView,
                              duration: 0.75,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.processedImageView.image = sortedImage
            })
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
            let correctedImage = originalImage.upOrientationImage() else { return }
        
        startIndicator()
        self.processedImageView.image = correctedImage
        
        picker.dismiss(animated: true) {
            
            DispatchQueue.global().async {
                
                if self.shouldProcessFullImage {
                    self.process(image: correctedImage)
                } else if let scaledImage = correctedImage.imageByScaling(toSize: correctedImage.size.scaledSize(maxLargerDimension: 1000)) {
                    self.process(image: scaledImage)
                }
            }
        }
    }
}
