//
//  HomeViewController.swift
//  PicFeed
//
//  Created by Robert Hatfield on 3/27/17.
//  Copyright © 2017 Robert Hatfield. All rights reserved.
//

import UIKit
import Social

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

        self.filterCollectionView.dataSource = self
        self.filterCollectionView.delegate = self
        setupGalleryDelegate()
        
    }
    
    func setupGalleryDelegate() {
        if let tabBarController = self.tabBarController {
            guard let viewControllers = tabBarController.viewControllers else { return }
            guard let galleryController = viewControllers[1] as? GalleryViewController else { return }
            galleryController.delegate = self
        }
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
    
//MARK User actions
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
        
        UIView.animate(withDuration: animationDuration) { 
            self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func userLongPressed(_ sender: UILongPressGestureRecognizer) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            guard let composeController = SLComposeViewController(forServiceType: SLServiceTypeTwitter) else {
                return
            }
            
            composeController.add(self.ImageView.image)
            self.present(composeController, animated: true, completion: nil)
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

        let targetSize = CGFloat(150)
        var resizeFactor : CGFloat
        if originalImage.size.height > originalImage.size.width {
            resizeFactor = targetSize / originalImage.size.width
        } else {
            resizeFactor = targetSize / originalImage.size.height
        }
        
        guard let resizedImage = originalImage.resize(size: CGSize(width: originalImage.size.width * resizeFactor, height: originalImage.size.height * resizeFactor)) else { return filterCell }
        
        let filterName = self.filterNames[indexPath.row]
        
        filterCell.filterLabel.text = filterName.rawValue
        
        Filters.shared.filter(name: filterName, image: resizedImage) { (filteredImage) in
            filterCell.imageView.image = filteredImage
        }
        
        return filterCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNames.count
    }

}

extension HomeViewController : GalleryViewControllerDelegate {
    func galleryController(didSelect image: UIImage) {
        self.ImageView.image = image
        Filters.originalImage = image
        Filters.shared.imageHistory.removeAll()
        Filters.shared.imageHistory.append(image)
                
        self.tabBarController?.selectedIndex = 0
        UIView.animate(withDuration: self.animationDuration) {
            self.filterViewHeightConstraint.constant = self.zeroConstant
            self.view.layoutIfNeeded()
        }
    }
}

extension HomeViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = Filters.originalImage
        Filters.shared.filter(name: filterNames[indexPath.row], image: image!, completion: { (filteredImage) in
            self.ImageView.image = filteredImage
            UIView.animate(withDuration: self.animationDuration) {
                self.filterViewHeightConstraint.constant = self.zeroConstant
                self.view.layoutIfNeeded()
            }
        })
    }
}
