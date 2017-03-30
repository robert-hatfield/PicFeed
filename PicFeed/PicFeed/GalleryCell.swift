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
    @IBOutlet weak var dateLabel: UILabel!
    
    var post: Post! {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            
            self.imageView.image = post.image
            self.dateLabel.text = dateFormatter.string(from: post.date!)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // clear image before cell is reused
        self.imageView.image = nil
    }
}
