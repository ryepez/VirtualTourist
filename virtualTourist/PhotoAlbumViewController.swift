//
//  PhotoAlbumViewController.swift
//  virtualTourist
//
//  Created by Ramon Yepez on 6/18/21.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
   
  

@IBOutlet weak var collectionView: UICollectionView!
@IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
@IBOutlet weak var mapView: MKMapView!
    
    //setting the container for the data 
    var pin: Pin!
    var photos:[Foto] = []
    //injecting the data source
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Foto>!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //delegates and data sources
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        // Do any additional setup after loading the view.
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        // do this later to add the hold touch to delete picture
        //collectionView.isUserInteractionEnabled = true
        NetworkRequests.getFotoLocation(url: NetworkRequests.Endpoints.getPictureOneMileRadius(String(pin.lat), String(pin.log)).url) { (reponse, error) in
        //saving the data to a object
            DataModel.photoArray = reponse
           // print(DataModel.photoArray)
        }
        
        settingUpOriginalLocation()
        settiUpFetchResults()
        
    
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        DataModel.photoArray = []
    }
    @IBAction func loadPictures(_ sender: UIButton) {
      
       
        collectionView.reloadData()
        
        }
    
    fileprivate func settingUpOriginalLocation() {
        //setting the initial location
        let initialLocation = CLLocation(latitude:pin.lat, longitude: pin.log)
        centerToLocation(initialLocation)
        
        //adding the pin
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.log)
        mapView.addAnnotation(annotation)
    }
    
    fileprivate func settiUpFetchResults() {
        //selects the first annotation so when going to the screen it shows selected
        
        
        let fetchRequest:NSFetchRequest<Foto> = Foto.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        //sorting the fetch request
        let sortDescriptor = NSSortDescriptor(key: "downloadDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription )")
        }
    }
    
    

     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataModel.photoArray.count
     }
     
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
        NetworkRequests.imageRequest(url: URL(string: DataModel.photoArray[(indexPath as NSIndexPath).row].url_sq)!) { (image, error) in
            
            DispatchQueue.main.async { [self] in
                let foto = Foto(context: self.dataController.viewContext)
                foto.downloadDate = Date()
                foto.imageToUse = image
                //saving the data
                try? self.dataController.viewContext.save()
                print(self.fetchedResultsController.fetchedObjects?.count)

            }
         
        }
        
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
               
       
        cell.imageView?.image = UIImage(named: "myimage")
        
    
        
        return cell
     }
     

    
 
}
//center map with location send from the previous scene
extension PhotoAlbumViewController {
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 1000
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        DispatchQueue.main.async {
            self.mapView.setRegion(coordinateRegion, animated: true)

        }
    }

}
