//
//  PhotoAlbumCollectionViewDelegateExtension.swift
//  Virtual Tourist
//
//  Created by Hanoudi on 5/19/20.
//  Copyright © 2020 Hanan. All rights reserved.
//

import Foundation
import UIKit

    //  MARK:- CollectionView Delegate Methods and Supporting Methods
extension PhotoAlbumViewController {
    // Supporting
    func deselectAll() {
        
           for index in collectionView.indexPathsForSelectedItems! {
               
               collectionView.deselectItem(at: index, animated: false)
               collectionView.cellForItem(at: index)?.contentView.alpha = 1
           }
       }
    
    func pickedToDeleteFromIndexPath(_ indexPathArray: [IndexPath]) -> [Int] {
        var selected:[Int] = []
        
        for index in indexPathArray {
            selected.append(index.row)
        }
        return selected
    }
    
    // Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
           return savedImagesOnPin.count
       }
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! CollectionViewCell
           
           cell.spinner.startAnimating()
           cell.loadImages(savedImagesOnPin[indexPath.row])
           return cell
       }
       
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           
           let width = UIScreen.main.bounds.width / 3 - gap
           let height = width
           return CGSize(width: width, height: height)
       }
       
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
           return gap
       }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           
           pickedImagesToDelete = pickedToDeleteFromIndexPath(collectionView.indexPathsForSelectedItems!)
           let cell = collectionView.cellForItem(at: indexPath)
           
           DispatchQueue.main.async {
               
               cell?.contentView.alpha = 0.3
           }
           
       }
       
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
           
           pickedImagesToDelete = pickedToDeleteFromIndexPath(collectionView.indexPathsForSelectedItems!)
           let cell = collectionView.cellForItem(at: indexPath)
           
           DispatchQueue.main.async {
               
               cell?.contentView.alpha = 1
           }
       }
}
