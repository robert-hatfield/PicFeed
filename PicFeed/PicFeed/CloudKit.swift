//
//  CloudKit.swift
//  PicFeed
//
//  Created by Robert Hatfield on 3/27/17.
//  Copyright © 2017 Robert Hatfield. All rights reserved.
//

import UIKit
import CloudKit

typealias SuccessCompletion = (Bool) -> ()
typealias PostsCompletion = ([Post]?) -> ()

class CloudKit {
    
    static let shared = CloudKit()
    
    let container = CKContainer.default()
    
    var privateDatabase : CKDatabase {
        return container.privateCloudDatabase
    }
    

    
    func save(post: Post, completion: @escaping SuccessCompletion) { // completion can also be referred to as a callback
        do {
            if let record = try Post.recordFor(post: post) {
                privateDatabase.save(record, completionHandler: { (record, error) in
                    if error != nil {
                        completion(false)
                        return
                    }
                    
                    if let record = record {
                        print(record)
                        completion(true)
                    } else {
                        completion(false)
                    }
                })
            }
        } catch { print(error) }
    }
    
    func getPosts(completion: @escaping PostsCompletion) {
        let postQuery = CKQuery(recordType: "Post", predicate: NSPredicate(value: true))
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        postQuery.sortDescriptors = [sort]
        
        self.privateDatabase.perform(postQuery, inZoneWith: nil) { (records, error) in
            
            if error != nil {
                OperationQueue.main.addOperation { completion(nil) }
            }
            
            if let records = records {
                var posts = [Post]()
                for record in records {
                    let uploadedDate = record.creationDate!
                    
                    print("Created: \(uploadedDate)")
                    if let asset = record["image"] as? CKAsset {
                        let path = asset.fileURL.path
                        if let image = UIImage(contentsOfFile: path) {
                            let newPost = Post(image: image, date: uploadedDate)
                            posts.append(newPost)
                        }
                    }
                }
                
            OperationQueue.main.addOperation { completion(posts) }
                
            }
        }
    }
    
}
