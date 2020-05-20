//
//  MainMapViewController.swift
//  Virtual Tourist
//
//  Created by Hanoudi on 5/18/20.
//  Copyright © 2020 Hanan. All rights reserved.
//
//  This class is responsible for handling all events in the main map view.
//  The main map view is the initial view in the Virtual Tourist App.
//  The controller handles gesture events to drop pins on the map.
//  A long press on the desired location drops a pin.
//  When a pin is tapped a segue to the PhotoAlbum Controller is triggered and transitioned to it.
//  This controller uses MapKit for handling the mapView and,
//  CoreData framework for handling object models, specifically the pins being dropped by the user

import UIKit
import MapKit
import CoreData

class MainMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    //  MARK:- Outlets & Variables
    @IBOutlet weak var mainMapView: MKMapView!
    var gestureDidBegin: Bool = false
    var inEditMode: Bool = false
    var currentPins: [Pin] = []
    let delegate = UIApplication.shared.delegate as! AppDelegate

    // MARK:- MainMapViewController's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createEditButton()
        loadPinsToMap()
        createAlert(withTitle: "Drop Pins", withMessage: "Long press on the desired location to drop a pin. Click any dropped pin to go to the Photo Album.")
    }
    // Perform Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        goToPhotoAlbum(segue, sender)
    }
    
    // Set Editing Mode
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // to display once
        if !inEditMode {
           createAlert(withTitle: "Editing Mode", withMessage: "Tap on pins to delete them.")
        }
        inEditMode = editing
    }
    
}

// ------------------------------------------------------------------------- //

//  MARK:- MainMapViewController's Extension
extension MainMapViewController {
    
    //  MARK:- Core Data Stack/ Data Controller Methods
    // get reference to core data controller from app delegate
    func getDataController() -> DataController {
        return delegate.dataController
    }
    
    // get fetchedResultsController
    func getFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let dataController = getDataController()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fetchRequest.sortDescriptors = []
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    // Load saved pins from core data stack
    func loadSavedPins() -> [Pin]? {
        
        do {
            var pins = [Pin]()
            let fetchedResultsController = getFetchedResultsController()
            
            try fetchedResultsController.performFetch()
            let numberOfPins = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            
            for index in 0..<numberOfPins {
                
                pins.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)) as! Pin)
            }
            return pins
            
        } catch {
            return nil
        }
    }
    
    // Add Data to Data Store
    func addDataToStore(pin: MKAnnotation) {
        
        do {
            let coordinates = pin.coordinate
            let pin = Pin(latitude: coordinates.latitude, longitude: coordinates.longitude, context: getDataController().context)
            try getDataController().saveContext()
            currentPins.append(pin)
            
        } catch {
            print("Adding data to store failed.")
        }
    }
    
    // Delete Data from Data Store
    func removeDataFromStore(pin: MKAnnotation) {
        
        let coordinates = pin.coordinate
        for pin in currentPins {
        
            if pin.latitude == coordinates.latitude && pin.longitude == coordinates.longitude {
                do {
                    getDataController().context.delete(pin)
                    try getDataController().saveContext()
                } catch {
                    print("Removing data from store failed.")
                }
                break
            }
        }
    }
    
// ------------------------------------------------------------------------- //
    //  MARK:- GestureRecognizer's Delegate Methods
    //  Asks delegate if recognizer should begin interpreting touches
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureDidBegin = true
        return true
    }
    
    //  MARK:- MapView's Delegate Methods
    //  Tells delegate that one of its annotations was selected, what to do?
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if !inEditMode {
            // Go to Photo Album.
            performSegue(withIdentifier: "PhotoAlbums", sender: view.annotation?.coordinate)
            mapView.deselectAnnotation(view.annotation, animated: false)
            
        } else {
            // If in edit mode remove selected pin.
            removeDataFromStore(pin: view.annotation!)
            mapView.removeAnnotation(view.annotation!)
        }
    }
    
// ------------------------------------------------------------------------- //
    //  MARK: UIMethods
    //  create edit button in navigation bar
    func createEditButton() {
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    //  add pin to map
    func addAnnotationToMap(cgPoint: CGPoint) {
        
        let coordinatesOfPin = mainMapView.convert(cgPoint, toCoordinateFrom: mainMapView)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinatesOfPin
        addDataToStore(pin: pin)
        mainMapView.addAnnotation(pin)
        
    }
    
    func addAnnotationToMap(coordinates: CLLocationCoordinate2D) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mainMapView.addAnnotation(annotation)
    }
    
    @IBAction func longGesture(_ sender: Any) {
        
        if gestureDidBegin {
            
            let gestureRecognizer = sender as! UILongPressGestureRecognizer
            let gestureTouchLocation = gestureRecognizer.location(in: mainMapView)
            addAnnotationToMap(cgPoint: gestureTouchLocation)
            gestureDidBegin = false
        }
    }
    
    func createAlert(withTitle title: String, withMessage message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    

// ------------------------------------------------------------------------- //
    fileprivate func loadPinsToMap() {
        let savedPins = loadSavedPins()
        if savedPins != nil {
            currentPins = savedPins!
            
            // add pins to map
            for pin in currentPins {
                let coordinates = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                addAnnotationToMap(coordinates: coordinates)
            }
        }
    }
    
    fileprivate func goToPhotoAlbum(_ segue: UIStoryboardSegue, _ sender: Any?) {
        if segue.identifier == "PhotoAlbums" {
            let destination = segue.destination as! PhotoAlbumViewController
            let coordinates = sender as! CLLocationCoordinate2D
            destination.selectedLocationCoordinate = coordinates
            
            for pin in currentPins {
                if pin.latitude == coordinates.latitude && pin.longitude == coordinates.longitude {
                    
                    destination.savedPinFromDataController = pin
                    break
                }
            }
        }
    }
}

