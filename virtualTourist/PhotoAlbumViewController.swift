//
//  PhotoAlbumViewController.swift
//  virtualTourist
//
//  Created by Ramon Yepez on 6/18/21.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
  

@IBOutlet weak var collectionView: UICollectionView!
        
@IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //delegates and data sources
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Do any additional setup after loading the view.
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        // do this later to add the hold touch to delete picture
        //collectionView.isUserInteractionEnabled = true

        
        NetworkRequests.getFotoLocation(url: NetworkRequests.Endpoints.getPictureOneMileRadius("37.9668", "-121.3692").url) { (reponse, error) in
        //saving the data to a object
            DataModel.photoArray = reponse
            //print(DataModel.photoArray.count)
        }
    }
    
    @IBAction func loadPictures(_ sender: UIButton) {
      
      
       
        collectionView.reloadData()
        
        }
    

     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataModel.photoArray.count
     }
     
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
               
        // Set the name and image
       
        NetworkRequests.imageRequest(url: URL(string: DataModel.photoArray[(indexPath as NSIndexPath).row].url_sq)!) { (image, error) in
            
            DispatchQueue.main.async {
                cell.imageView?.image = image
            }
        }
    
        
        return cell
     }
     

   // Marks: making the collectionView look better
    
 
}
//center map with location send from the previous scene
extension MKMapView {
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 1000
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }

}
