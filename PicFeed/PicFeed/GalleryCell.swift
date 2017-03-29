//
//  GalleryCell.swift
//  PicFeed
//
//  Created by Robert Hatfield on 3/29/17.
//  Copyright © 2017 Robert Hatfield. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var post: Post! {
        didSet {
            self.imageView.image = post.image
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // clear image before cell is reused
        self.imageView.image = nil
    }
}
