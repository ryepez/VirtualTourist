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
        
        //hidding the navigation controller
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        mapView.delegate = self
        setupLastMapLocation()
        
    }

    //helper method to load the user last map that he was looking at
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

