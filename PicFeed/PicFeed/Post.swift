//
//  Post.swift
//  PicFeed
//
//  Created by Robert Hatfield on 3/28/17.
//  Copyright © 2017 Robert Hatfield. All rights reserved.
//

import UIKit
import CloudKit

class Post {
    let image : UIImage
    
    init(image: UIImage) {
        self.image = image
    }
}



enum PostError : Error {
    case writingImageToData
    case writingDataToDisk
}

// best practice per Apple is to keep classes lightweight, and use extensions to add capabilities like CloudKit
extension Post {
    
    class func recordFor(post: Post) throws -> CKRecord? {
        guard let data = UIImageJPEGRepresentation(post.image, 0.7) else { throw PostError.writingImageToData }
        
        do {
            try data.write(to: post.image.path)
            // the lines below will execute if the try statement above is successful
            let asset = CKAsset(fileURL: post.image.path)
            let record = CKRecord(recordType: "Post")
            record.setValue(asset, forKey: "image")
            return record
        } catch {
            throw PostError.writingDataToDisk
        }
    }
    
}
