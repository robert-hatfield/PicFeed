//
//  HomeViewController.swift
//  PicFeed
//
//  Created by Robert Hatfield on 3/27/17.
//  Copyright © 2017 Robert Hatfield. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var filterButtonTopConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        filterButtonTopConstraint.constant = 8
        
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }

    func presentImagePickerWith(sourceType: UIImagePickerControllerSourceType) {
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = sourceType
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil) // this will dismiss the topmost view controller
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Info: \(info)")
        
        if let originalImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.ImageView.image = originalImage
            Filters.originalImage = originalImage
            print("Used edited image")
        }
        else {
            if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.ImageView.image = originalImage
                Filters.originalImage = originalImage
                print("Used original image")
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func imageTapped(_ sender: Any) {
        print("User tapped image!")
        self.presentActionSheet()
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        if let image = self.ImageView.image {
            let newPost = Post(image: image)
            CloudKit.shared.save(post: newPost, completion: { (success) in
                if success {
                    print("Saved post successfully to CloudKit")
                } else {
                    print("Post was NOT successfully saved to CloudKit")
                }
            })
        }
    }
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        guard let image = self.ImageView.image else { return }
        let alertController = UIAlertController(title: "Filter", message: "Please select a filter to apply.", preferredStyle: .alert)
        let blackAndWhiteAction = UIAlertAction(title: "Black & White", style: .default) { (action) in
            Filters.filter(name: .blackAndWhite, image: image, completion: { (filteredImage) in
                self.ImageView.image = filteredImage
            })
        }
        let vintageAction = UIAlertAction(title: "Vintage", style: .default) { (action) in
            Filters.filter(name: .vintage, image: image, completion: { (filteredImage) in
                self.ImageView.image = filteredImage
            })
        }
        let resetAction = UIAlertAction(title: "Reset Image", style: .destructive) { (action) in
            self.ImageView.image = Filters.originalImage
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(blackAndWhiteAction)
        alertController.addAction(vintageAction)
        alertController.addAction(resetAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func presentActionSheet() {
        
        let actionSheetController = UIAlertController(title: "Source", message: "Please select Source Type", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.presentImagePickerWith(sourceType: .camera)
            self.imagePicker.allowsEditing = true
        }
        
        let photoAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.presentImagePickerWith(sourceType: .photoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheetController.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionSheetController.addAction(photoAction)
        }
        
        if UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.pad {
            actionSheetController.addAction(cancelAction)
        }
        
        let popover = actionSheetController.popoverPresentationController
        popover?.sourceView = ImageView
        popover?.sourceRect = ImageView.bounds
        popover?.permittedArrowDirections = UIPopoverArrowDirection.any
            
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    func wordCount(ofString string: String) -> Int {
        
        var words = [String]()
        let range = Range<String.Index>(uncheckedBounds: (lower: string.startIndex, upper: string.endIndex))
        
        string.enumerateSubstrings(in: range, options: .byWords) { (word, _, _, _) in
            words.append(word!)
        }
        
        return words.count
        
    }
}
