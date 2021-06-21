//
//  TraveLocationMapController.swift
//  virtualTourist
//
//  Created by Ramon Yepez on 6/16/21.
//

import UIKit
import MapKit

class TraveLocationMapController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
           
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //hidding the navigation controller
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func addAnnotation(location: CLLocationCoordinate2D){
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = "Some Title"
            self.mapView.addAnnotation(annotation)
    }
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
            pinView!.isDraggable = true

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

