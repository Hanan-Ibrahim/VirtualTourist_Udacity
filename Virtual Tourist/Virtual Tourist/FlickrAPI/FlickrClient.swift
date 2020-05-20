//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Hanoudi on 5/18/20.
//  Copyright © 2020 Hanan. All rights reserved.
//
//  This is the class that is responsible for creating URLs using FLickr's API


import Foundation

class FlickrClient {
    
    // MARK:- Components of URL
    // private because no other class has the authority to access auth keys
    
    private static let baseURL = "https://api.flickr.com/services/rest/"
    private static let key     = "5aefe7e712560d184b084aefd5277b84"
    private static let search  = "flickr.photos.search"
    private static let format  = "json"
    private static let radius  = 10
    
    //  MARK:- Methods
    //  download images
    static func downloadImages(latitude: Double, longitude: Double, completion: @escaping (_ success: Bool, _ flickrImages:[FlickrImage]?) -> Void) {
        
        // create a url of the request of images
        let request = NSMutableURLRequest(url: URL(string: "\(baseURL)?method=\(search)&format=\(format)&api_key=\(key)&lat=\(latitude)&lon=\(longitude)&radius=\(radius)")!)
        
        // start a session
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            if error != nil {
                completion(false, nil)
                // return
                fatalError(error!.localizedDescription)
            }
            
            // remove extra chars from beginning to be able to parse response
            let range = Range(uncheckedBounds: (14, data!.count - 1))
            let newData = data?.subdata(in: range)
            
            // Serialization
            if let json = try? JSONSerialization.jsonObject(with: newData!) as? [String:Any],
                let imagesMETA = json["photos"] as? [String:Any],
                let images = imagesMETA["photo"] as? [Any] {
                
                var flickrImages:[FlickrImage] = []
                
                for image in images {
                    // instead of using :Codable
                    if let flickrImage = image as? [String:Any],
                       let id = flickrImage["id"] as? String,
                       let secret = flickrImage["secret"] as? String,
                       let server = flickrImage["server"] as? String,
                       let farm = flickrImage["farm"] as? Int {
                        
                        flickrImages.append(FlickrImage(id: id, secret: secret, server: server, farm: farm))
                    }
                }
                
                completion(true, flickrImages)
                
            } else {
                
                completion(false, nil)
            }
        }
        // call from background
        task.resume()
    }
}
