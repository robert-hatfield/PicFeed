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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
        if let newImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.ImageView.image = newImage
            print("Used edited image")
        } else {
            if let newImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.ImageView.image = newImage
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
        
        actionSheetController.addAction(cancelAction)
        
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
