//
//  HomeViewController.swift
//  PicFeed
//
//  Created by Robert Hatfield on 3/27/17.
//  Copyright © 2017 Robert Hatfield. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let filterNames = [FilterName.blackAndWhite, FilterName.vintage, FilterName.bloom, FilterName.halftone, FilterName.sharpen]
    let imagePicker = UIImagePickerController()
    let animationDuration = 0.4
    let marginConstant = CGFloat(8)
    let zeroConstant = CGFloat(0)
    let endFilterViewHeight = CGFloat(150)
    
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var filterCollectionView: UICollectionView!
    
    @IBOutlet weak var filterButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.filterCollectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        filterButtonTopConstraint.constant = marginConstant
        postButtonLeadingConstraint.constant = zeroConstant
        saveButtonTrailingConstraint.constant = zeroConstant
        
        UIView.animate(withDuration: animationDuration) {
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
            Filters.shared.imageHistory.removeAll()
            Filters.shared.imageHistory.append(originalImage)
            Filters.originalImage = originalImage
            self.filterCollectionView.reloadData()
        }
        else {
            if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.ImageView.image = originalImage
                Filters.shared.imageHistory.removeAll()
                print("removed history")
                Filters.shared.imageHistory.append(originalImage)
                Filters.originalImage = originalImage
                self.filterCollectionView.reloadData()
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
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("A save error occurred: \(error.localizedDescription)")
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(ImageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        guard let image = self.ImageView.image else { return }
        
        switch self.filterViewHeightConstraint.constant {
        case zeroConstant:
            self.filterViewHeightConstraint.constant = endFilterViewHeight
        case endFilterViewHeight:
            self.filterViewHeightConstraint.constant = zeroConstant
        default:
            return
        }
//        self.filterViewHeightConstraint.constant = filterViewHeight
        
        UIView.animate(withDuration: animationDuration) { 
            self.view.layoutIfNeeded()
        }
        
//        let alertController = UIAlertController(title: "Filter", message: "Please select a filter to apply.", preferredStyle: .alert)
//        
//        let blackAndWhiteAction = UIAlertAction(title: "Black & White", style: .default) { (action) in
//            Filters.shared.filter(name: .blackAndWhite, image: image, completion: { (filteredImage) in
//                self.ImageView.image = filteredImage
//            })
//        }
//        let vintageAction = UIAlertAction(title: "Vintage", style: .default) { (action) in
//            Filters.shared.filter(name: .vintage, image: image, completion: { (filteredImage) in
//                self.ImageView.image = filteredImage
//            })
//        }
//        let bloomAction = UIAlertAction(title: "Bloom", style: .default) { (action) in
//            Filters.shared.filter(name: .bloom, image: image, completion: { (filteredImage) in
//                self.ImageView.image = filteredImage
//            })
//        }
//        let sharpenAction = UIAlertAction(title: "Sharpen", style: .default) { (action) in
//            Filters.shared.filter(name: .sharpen, image: image, completion: { (filteredImage) in
//                self.ImageView.image = filteredImage
//            })
//        }
//        let halftoneAction = UIAlertAction(title: "Halftone", style: .default) { (action) in
//            Filters.shared.filter(name: .halftone, image: image, completion:  { (filteredImage) in
//                self.ImageView.image = filteredImage
//            })
//        }
//        
//        let undoAction = UIAlertAction(title: "Undo last", style: .destructive) { (action) in
//            if Filters.shared.imageHistory.count > 1 {
//                Filters.shared.imageHistory.removeLast()
//                self.ImageView.image = Filters.shared.imageHistory.last
//            }
//        }
//        
//        let resetAction = UIAlertAction(title: "Reset Image", style: .destructive) { (action) in
//            
//            self.ImageView.image = Filters.shared.imageHistory[0]
//            if Filters.shared.imageHistory.count > 1 {
//                Filters.shared.imageHistory.removeSubrange(1..<Filters.shared.imageHistory.count)
//            }
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        alertController.addAction(blackAndWhiteAction)
//        alertController.addAction(vintageAction)
//        alertController.addAction(bloomAction)
//        alertController.addAction(halftoneAction)
//        alertController.addAction(sharpenAction)
//        alertController.addAction(undoAction)
//        
//        // Do not show reset unless there are 2 or more filters applied
//        if Filters.shared.imageHistory.count > 2 {
//            alertController.addAction(resetAction)
//        }
//        
//        alertController.addAction(cancelAction)
//        
//        // Disable undo if there are no filters applied
//        if Filters.shared.imageHistory.count < 2 {
//            undoAction.isEnabled = false
//        }
//        
//        self.present(alertController, animated: true, completion: nil)
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

//MARK: UICollectionView DataSource
extension HomeViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let filterCell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterPreviewCell.identifier, for: indexPath) as! FilterPreviewCell
        
        guard let originalImage = Filters.originalImage as UIImage? else { return filterCell }
// This may need to be refactored with optionals if there is no image in the imageView
//        else { return filterCell }
        let targetSize = CGFloat(150)
        var resizeFactor : CGFloat
//        guard let resizedImage = originalImage.resize(size: CGSize(width: 150, height: 150)) else { return filterCell }
        
        if originalImage.size.height > originalImage.size.width {
            resizeFactor = targetSize / originalImage.size.width
        } else {
            resizeFactor = targetSize / originalImage.size.height
        }
        print("Original height: \(originalImage.size.height)\nOriginal width: \(originalImage.size.width)\nResize factor: \(resizeFactor)")
        print("New size: \(originalImage.size.width * resizeFactor)w x \(originalImage.size.height * resizeFactor)h")
        guard let resizedImage = originalImage.resize(size: CGSize(width: originalImage.size.width * resizeFactor, height: originalImage.size.height * resizeFactor)) else { return filterCell }
        
        let filterName = self.filterNames[indexPath.row]
        
        Filters.shared.filter(name: filterName, image: resizedImage) { (filteredImage) in
            filterCell.imageView.image = filteredImage
        }
        
        return filterCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNames.count
    }
}
