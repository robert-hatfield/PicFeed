//
//  Filters.swift
//  PicFeed
//
//  Created by Robert Hatfield on 3/28/17.
//  Copyright © 2017 Robert Hatfield. All rights reserved.
//

import UIKit

let vintageFilter = ["name": "Vintage", "ciName": "CIPhotoEffectTransfer"]
let bwFilter = ["name": "Black & White", "ciName": "CIPhotoEffectMono"]
let bloomFilter = ["name": "Bloom", "ciName": "CIBloom"]
let sharpenFilter = ["name": "Sharpen", "ciName": "CISharpenLuminance"]
let halftoneFilter = ["name": "Halftone", "ciName": "CICMYKHalftone"]


typealias FilterCompletion = (UIImage?) -> ()

class Filters {

    let allFilters = [vintageFilter, bwFilter, bloomFilter, sharpenFilter, halftoneFilter]
    
    var ciContext : CIContext
    
    var imageHistory = [UIImage]()
    static var originalImage : UIImage?
    
    static let shared = Filters()
    
    private init() {
        // Create GPU Context
        let options = [kCIContextWorkingColorSpace: NSNull()]
        guard let eaglContext = EAGLContext(api: .openGLES2) else { fatalError("Failed to create EAGLContext") }
        self.ciContext = CIContext(eaglContext: eaglContext, options: options)
    }
    
     func filter(name: String, image: UIImage, completion: @ escaping FilterCompletion) {
        OperationQueue().addOperation {
            guard let filter = CIFilter(name: name) else { fatalError("Failed to create CIFilter") }
            let coreImage = CIImage(image: image)
            filter.setValue(coreImage, forKey: kCIInputImageKey)
            
            // Get filtered image from GPU
            guard var outputImage = filter.outputImage else { fatalError("Failed to get output Image from filter") }
            
            if name == "CIBloom" {
                // necessary because the filter is resizing the image
                outputImage = outputImage.cropping(to: (coreImage?.extent)!)
            }
            
            if let cgImage = self.ciContext.createCGImage(outputImage, from: outputImage.extent) {

                
                let finalImage = UIImage(cgImage: cgImage)
                OperationQueue.main.addOperation {
//                    print("history count: \(self.imageHistory.count)")
                    self.imageHistory.append(finalImage)
                    completion(finalImage)
                }
            } else {
                OperationQueue.main.addOperation {
                    completion(nil)
                }
            }
        }
    }
}
