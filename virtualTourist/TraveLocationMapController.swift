//
//  TraveLocationMapController.swift
//  virtualTourist
//
//  Created by Ramon Yepez on 6/16/21.
//

import UIKit
import MapKit
import CoreData

class TraveLocationMapController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    // the pins who photos are being displayed
    var pins: [Pin] = []
    //maybe I dont need this here check later
    var photos:[Foto] = []
    
    var dataController:DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting the map delegate
        mapView.delegate = self

        //hidding the navigation controller
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        
        //load last position of last map looked at
        setupLastMapLocation()
        
        //creating the gesture hold and press
        let dropPin = UILongPressGestureRecognizer(target: self, action: #selector(holdToDrop))
         mapView.addGestureRecognizer(dropPin)
        
        //creatign a fetchRequest
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        //sorting the fetch request
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //geting fetch and saving on the pin array
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
        
            //put the pins from storage on the screen
            displayPinFromStorage()
            
                }
        
    }
    
    func displayPinFromStorage() {
       
        for index in pins {
            let annotation = MKPointAnnotation()
            let location = CLLocationCoordinate2D(latitude: index.lat, longitude: index.log)
            annotation.coordinate = location
            annotation.title = "Photos"
            self.mapView.addAnnotation(annotation)

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //hidding the navigation controller
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func addAnnotation(location: CLLocationCoordinate2D){
            
      
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Photos"
        //self.mapView.addAnnotation(annotation)
        
        //seting the pin data and saving it
        let pin = Pin(context: dataController.viewContext)
        pin.creationDate = Date()
        pin.lat = annotation.coordinate.latitude
        pin.log = annotation.coordinate.longitude
        //saving the data
        //inserting the pin on the pins array
        pins.insert(pin, at: 0)
      
        self.mapView.addAnnotation(annotation)
        try? dataController.viewContext.save()

        
    }
     
        
    
        //mapView.addAnnotation(annotation)
        
        
    
    @objc func holdToDrop(sender: UIGestureRecognizer){
        if sender.state == .ended {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            
            addAnnotation(location: locationOnMap)
        }
        
        
    }

    //helper method to load the user last map that user was looking at
    fileprivate func setupLastMapLocation() {
        let isSliderSet = UserDefaults.standard.bool(forKey: "lastMapLocation")
        
        if isSliderSet {
            if let latitude = UserDefaults.standard.value(forKey: "lastMapLocationLatitude"), let longitude = UserDefaults.standard.value(forKey: "lastMapLocationLongitude"), let latitudeDelta = UserDefaults.standard.value(forKey: "latitudeDelta"), let longitudeDelta = UserDefaults.standard.value(forKey: "longitudeDelta") {
                
                let initialLocation = CLLocation(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
                
                self.centerMapOnLocation(location: initialLocation, latitudeDelta: latitudeDelta as! Double, longitudeDelta: longitudeDelta as! Double)
            }
            
        } else {
            UserDefaults.standard.set(true, forKey: "lastMapLocation")
        }
    }
    
    // this method controls the look of the pins and displays the data in a better format
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
          //  pinView!.isDraggable = true

            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // Method does the segue when user taps the pin
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
         
            performSegue(withIdentifier: "photoAlbumViewController", sender: self)

        }
    }
    
    var numberOfPhotos: Int { return photos.count }
    
    func photo(at indexPath: IndexPath) -> Foto {
        return photos[indexPath.row]
    }
    
    func addPin() {
        
    }
    
}




extension TraveLocationMapController: MKMapViewDelegate {

    func centerMapOnLocation(location: CLLocation, latitudeDelta: Double, longitudeDelta: Double) {
       let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
        
        DispatchQueue.main.async {
           self.mapView.setRegion(region, animated: true)
       }
        
   }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //storing the latitude and longitude of the center of the map when it moves
        let mapLatitude = mapView.centerCoordinate.latitude
        let mapLongitude = mapView.centerCoordinate.longitude
        
        //storing these values for getting the correct zoom to restruct the map for the user after the close the app.
        let latitudeDeltaZoom = mapView.region.span.latitudeDelta
        let longitudeDeltaDeltaZoom = mapView.region.span.longitudeDelta

        //setting the values of map everytime that the map moves
        UserDefaults.standard.set(mapLatitude, forKey: "lastMapLocationLatitude")
        UserDefaults.standard.set(mapLongitude, forKey: "lastMapLocationLongitude")
        UserDefaults.standard.set(latitudeDeltaZoom, forKey: "latitudeDelta")
        UserDefaults.standard.set(longitudeDeltaDeltaZoom, forKey: "longitudeDelta")
            
    }

}

