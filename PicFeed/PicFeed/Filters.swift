//
//  Filters.swift
//  PicFeed
//
//  Created by Robert Hatfield on 3/28/17.
//  Copyright © 2017 Robert Hatfield. All rights reserved.
//

import UIKit

enum FilterNamed : String {
    case vintage = "CIPhotoEffectTransfer"
    case blackAndWhite = "CIPhotoEffectMono"
}

typealias FilterCompletion = (UIImage?) -> ()

class Filters {
    
    static var originalImage = UIImage()
    
}
