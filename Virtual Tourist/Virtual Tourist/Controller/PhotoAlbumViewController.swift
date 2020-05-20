//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Hanoudi on 5/19/20.
//  Copyright © 2020 Hanan. All rights reserved.
//
//  This controller is responsbile for handling events in the Photo Album View.
//  This the delegate of the collection view embedded within it.
//  This controller handles deletion of photos from album upon selection.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //  MARK:- Outlets and variables
    let delegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet var noImages: UILabel!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // variables related to data controller/ core data stack
    var dataController: DataController!
    var savedPinFromDataController: Pin!
    var savedImagesOnPin = [Image]()
    var pickedImagesToDelete = [Int]() {
        didSet {
            if pickedImagesToDelete.count > 0 {
                newCollectionButton.setTitle("Delete selected images.", for: .normal)
                newCollectionButton.backgroundColor = UIColor.red
                newCollectionButton.setTitleColor(.white, for: .normal)
            } else {
                newCollectionButton.setTitle("New Collection", for: .normal)
            }
        }
    }
    
    // variables related collection view
    let gap: CGFloat = 5
    let numberOfCells: Int = 25
    var selectedLocationCoordinate: CLLocationCoordinate2D!

// ---------------------------------------------------------------------- //
    //  MARK:- PhotoAlbumViewController's View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setFlowLayout()
        addPin()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        
        newCollectionButton.isHidden = false
        noImages.isHidden = true
    
        retriveImages()
    }
    
// ---------------------------------------------------------------------- //
    //  MARK:- UIMethods
    @IBAction func newCollectionButtonTapped(_ sender: Any) {
        
        if pickedImagesToDelete.count > 0 {
            
            deleteSelectedImagesFromStore()
            deselectAll()
            savedImagesOnPin = loadSavedImages()!
            displayFinalImages()
            
        } else {
            displayNewImages()
        }
    }
}

 // ---------------------------------------------------------------------- //
//  MARK:- PhotoAlbumViewController Extension
extension PhotoAlbumViewController {
    
        //  MARK:- Core Data Stack/ Data Controller Methods
        // get reference to core data controller from app delegate
        func getDataController() -> DataController {
            return delegate.dataController
        }
        
        // get fetchedResultsController
        func getFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
            
            let dataController = getDataController()
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
            fetchRequest.sortDescriptors = []
            fetchRequest.predicate = NSPredicate(format: "pin = %@", argumentArray: [savedPinFromDataController!])
            
            return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.context, sectionNameKeyPath: nil, cacheName: nil)
        }
        
        // Load saved photos from data core stack
        func loadSavedImages() -> [Image]? {
            
            do {
                var images = [Image]()
                let fetchedResultsController = getFetchedResultsController()
                try fetchedResultsController.performFetch()
                let numberOfImages = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
                
                for index in 0..<numberOfImages {
                    images.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)) as! Image)
                }
                
                return images.sorted(by: {$0.index < $1.index})
                
            } catch {
                return nil
            }
        }
    
    // Delete selected images
    func deleteSelectedImagesFromStore() {
        
        for index in 0..<savedImagesOnPin.count {
            
            if pickedImagesToDelete.contains(index) {
                getDataController().context.delete(savedImagesOnPin[index])
            }
        }
        
        do {
            try getDataController().saveContext()
            
        } catch {
            
            print("Deleting Images from data store failed.")
        }
        pickedImagesToDelete.removeAll()
    }
    
    //  add images to data store
       func addImagesToDataController(flickrImages:[FlickrImage], pin:Pin) {
           
           for image in flickrImages {
               
               do {
                   let dataController = delegate.dataController
                   let image = Image(index: flickrImages.firstIndex{$0 === image}!, imageURL: image.imageURLString(), imageData: nil, context: dataController.context)
                   image.pin = pin
                   try dataController.saveContext()
                   
               } catch {
                   
                   print("Add Core Data Failed")
               }
           }
       }
       
       // delete images from data store
       func deleteImagesFromStore() {
           for image in savedImagesOnPin {
               getDataController().context.delete(image)
           }
       }
    
        
// ---------------------------------------------------------------------- //
        //  MARK:- Supporting Methods
        func displayFinalImages() {
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }

        func displayNewImages() {
            
            newCollectionButton.isEnabled = false
            
            deleteImagesFromStore()
            savedImagesOnPin.removeAll()
            collectionView.reloadData()
            
            loadStochasticImages { (flickrImages) in
                
                if flickrImages != nil {
                    
                    DispatchQueue.main.async {
                        
                        self.addImagesToDataController(flickrImages: flickrImages!, pin:
                            self.savedPinFromDataController)
                        self.savedImagesOnPin = self.loadSavedImages()!
                        self.displayFinalImages()
                        self.newCollectionButton.isEnabled = true
                    }
                }
            }
        }
        
       
        
        func loadStochasticImages(completion: @escaping (_ result:[FlickrImage]?) -> Void) {
            
            var newImages = [FlickrImage]()
            FlickrClient.downloadImages(latitude: selectedLocationCoordinate.latitude, longitude: selectedLocationCoordinate.longitude) { (success, flickrImages) in
                if success {
                    
                    if flickrImages!.count > self.numberOfCells {
                        var stochasticImages:[Int] = []
                        
                        while stochasticImages.count < self.numberOfCells {
                            
                            let random = arc4random_uniform(UInt32(flickrImages!.count))
                            if !stochasticImages.contains(Int(random)) { stochasticImages.append(Int(random)) }
                        }
                        
                        for randImage in stochasticImages {
                            
                            newImages.append(flickrImages![randImage])
                        }
                        
                        completion(newImages)
                        
                    } else {
                        
                        completion(flickrImages!)
                    }
                    
                } else {
                    completion(nil)
                }
            }
        }
        
        func addPin() {
            
            let pin = MKPointAnnotation()
            pin.coordinate = selectedLocationCoordinate
            mapView.addAnnotation(pin)
            mapView.showAnnotations([pin], animated: true)
        }

    // -------------------------------------------------------------- //
    fileprivate func setFlowLayout() {
        //Flow Layout
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = gap
        flowLayout.minimumLineSpacing = gap
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    fileprivate func retriveImages() {
        let savedPhoto = loadSavedImages()
        if savedPhoto != nil && savedPhoto?.count != 0 {
            savedImagesOnPin = savedPhoto!
            displayFinalImages()
            
        } else {
            displayNewImages()
        }
    }
        
}
