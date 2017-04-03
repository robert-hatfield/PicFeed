//
//  HomeViewController.swift
//  PicFeed
//
//  Created by Robert Hatfield on 3/27/17.
//  Copyright © 2017 Robert Hatfield. All rights reserved.
//

import UIKit
import Social

class HomeViewController: UIViewController, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    let normalAnimationDuration = 0.4
    let shortAnimationDuration = 0.2
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
        
        UIView.animate(withDuration: normalAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }

    
//MARK: User actions
    
    @IBAction func imageTapped(_ sender: Any) {
        UIView.animate(withDuration: self.shortAnimationDuration) {
            self.filterViewHeightConstraint.constant = self.zeroConstant
            self.view.layoutIfNeeded()
        }
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
        if Filters.shared.imageHistory.count > 0 {
            print("\(Filters.shared.imageHistory.count)")
            switch self.filterViewHeightConstraint.constant {
            case zeroConstant:
                self.filterViewHeightConstraint.constant = endFilterViewHeight
            case endFilterViewHeight:
                self.filterViewHeightConstraint.constant = zeroConstant
            default:
                return
            }
            
            UIView.animate(withDuration: normalAnimationDuration) {
                self.view.layoutIfNeeded()
            }
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
        
        typealias sourceAction = (title: String, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)?, conditional: Bool?)
        
        let cameraAction: sourceAction = (title: "Camera", style: .default, handler: {(UIAlertAction) in
            self.presentImagePickerWith(sourceType: .camera)
            self.imagePicker.allowsEditing = true}, conditional: UIImagePickerController.isSourceTypeAvailable(.camera)
        )
        
        let photoAction: sourceAction = (title: "Photo Library", style: .default, handler: {(UIAlertAction) in
            self.presentImagePickerWith(sourceType: .photoLibrary)
        }, conditional: UIImagePickerController.isSourceTypeAvailable(.photoLibrary))
        
        let cancelAction: sourceAction = (title:"Cancel", style: .destructive, handler: nil, conditional: UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.pad)
        
        let sourceActions = [cameraAction, photoAction, cancelAction]
        
        for actionDefinition in sourceActions {
            let action = UIAlertAction(title: actionDefinition.title, style: actionDefinition.style, handler: actionDefinition.handler)
            if actionDefinition.conditional == true { actionSheetController.addAction(action) }
        }
        
        if let popover = actionSheetController.popoverPresentationController {
            popover.sourceView = ImageView
            popover.sourceRect = ImageView.bounds
            popover.permittedArrowDirections = .init(rawValue: 0)
        }
        
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

//MARK: UICollectionView extensions
extension HomeViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let filterCell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterPreviewCell.identifier, for: indexPath) as! FilterPreviewCell
        
        guard let originalImage = Filters.shared.imageHistory.last as UIImage? else { return filterCell }

        let targetSize = CGFloat(150)
        var resizeFactor : CGFloat
        if originalImage.size.height > originalImage.size.width {
            resizeFactor = targetSize / originalImage.size.width
        } else {
            resizeFactor = targetSize / originalImage.size.height
        }
        
        guard let resizedImage = originalImage.resize(size: CGSize(width: originalImage.size.width * resizeFactor, height: originalImage.size.height * resizeFactor)) else { return filterCell }
        
        let filter = Filters.shared.allFilters[indexPath.row]
        
        filterCell.filterLabel.text = filter["name"]
        
        Filters.shared.filter(name: filter["ciName"]!, image: resizedImage) { (filteredImage) in
            filterCell.imageView.image = filteredImage
        }
        
        return filterCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Filters.shared.allFilters.count
    }

}

//MARK: GalleryViewController extension
extension HomeViewController : GalleryViewControllerDelegate {
    func galleryController(didSelect image: UIImage) {
        self.ImageView.image = image
        Filters.originalImage = image
        Filters.shared.imageHistory.removeAll()
        Filters.shared.imageHistory.append(image)
                
        self.tabBarController?.selectedIndex = 0
        UIView.animate(withDuration: self.normalAnimationDuration) {
            self.filterViewHeightConstraint.constant = self.zeroConstant
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: UICollectionView extension
extension HomeViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = Filters.shared.imageHistory.last
        Filters.shared.filter(name: Filters.shared.allFilters[indexPath.row]["ciName"]!, image: image!, completion: { (filteredImage) in
            self.ImageView.image = filteredImage
            Filters.shared.imageHistory.append(filteredImage!)
            UIView.animate(withDuration: self.normalAnimationDuration) {
                self.filterViewHeightConstraint.constant = self.zeroConstant
                self.view.layoutIfNeeded()
            }
        })
    }
}

//MARK: UIImagePickerController extension
extension HomeViewController : UIImagePickerControllerDelegate {
    func presentImagePickerWith(sourceType: UIImagePickerControllerSourceType) {
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = sourceType
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil) // this will dismiss the topmost view controller
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
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

}
