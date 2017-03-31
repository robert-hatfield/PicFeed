//
//  FilterPreviewCell.swift
//  PicFeed
//
//  Created by Robert Hatfield on 3/30/17.
//  Copyright © 2017 Robert Hatfield. All rights reserved.
//

import UIKit

class FilterPreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var filterLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // clear image before cell is reused
        self.imageView.image = nil
    }
}
