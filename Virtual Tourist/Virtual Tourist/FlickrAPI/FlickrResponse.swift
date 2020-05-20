//
//  FlickrResponse.swift
//  Virtual Tourist
//
//  Created by Hanoudi on 5/18/20.
//  Copyright © 2020 Hanan. All rights reserved.
//
// This is the response of thre request to getting an image off Flickr using its API

import UIKit
import CoreData

class FlickrImage {
    
    //  MARK:- Response Components
    let id:     String
    let secret: String
    let server: String
    let farm:   Int
    
    //  MARK:- Initializer
    init(id: String, secret: String, server: String, farm: Int) {
        
        self.id = id
        self.secret = secret
        self.server = server
        self.farm = farm
    }
        
}

//  MARK:- FlickrImage's Extension
extension FlickrImage {
    
    // MARK:- get URL to Image
    func imageURLString() -> String {
        let url = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
        return url
    }
    
}
