//
//  CollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Hanoudi on 5/18/20.
//  Copyright © 2020 Hanan. All rights reserved.
//
//  This is the controller reponsible for cells in the collection view
//  It is responsible for downloading and retriving images from store

import Foundation
import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    //  MARK:- Outlets
    let delegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    

    func loadImages(_ image: Image) {
        
        if image.imageData != nil {
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: image.imageData! as Data)
                self.spinner.stopAnimating()
            }
            
        } else {
            download(image)
        }
    }
}

// ---------------------------------------------------------------------- //
//  MARK:- CollectionViewCell's Extension
extension CollectionViewCell {
   
    //  MARK:- Methods
    func download(_ image: Image) {
        
        URLSession.shared.dataTask(with: URL(string: image.imageURL!)!) { (data, response, error) in
            
            if error == nil {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data! as Data)
                    self.spinner.stopAnimating()
                    self.saveImageToDataController(image: image, imageData: data! as NSData)
                }
             }
          }
            .resume()
    }
    
    func saveImageToDataController(image: Image, imageData: NSData) {
        do {
            image.imageData = imageData
            let dataController = delegate.dataController
            try dataController.saveContext()
          } catch {
            print("Saving image failed.")
        }
    }
}
