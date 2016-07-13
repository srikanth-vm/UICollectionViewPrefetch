//
//  Photos.swift
//  PrefetchDemo
//
//  Created by Madhusudhan, Srikanth on 7/12/16.
//  Copyright © 2016 GoodSp33d. All rights reserved.
//

import Foundation

class Photos {
    
    let currentPage:Int
    let totalPages:Int
    let totalItems:Int
    var photos = [Photo]()
    
    init(jsonDictionary:[String:AnyObject]) {
        currentPage = jsonDictionary["current_page"] as? Int ?? 0
        totalPages = jsonDictionary["total_pages"] as? Int ?? 0
        totalItems = jsonDictionary["total_items"] as? Int ?? 0
        
        if let photos = jsonDictionary["photos"] as? [AnyObject] {
            for eachPhoto in photos {
                if let p = eachPhoto as? [String:AnyObject] {
                    self.photos.append(Photo(jsonDictionary: p))
                }
            }
        }
    }
}

class Photo {
    
    let photoURL:String
    
    init(jsonDictionary:[String:AnyObject]) {
        photoURL = jsonDictionary["image_url"] as? String ?? ""
    }
}
