//
//  PhotoAlbumViewController.swift
//  virtualTourist
//
//  Created by Ramon Yepez on 6/18/21.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
  

@IBOutlet weak var collectionView: UICollectionView!
@IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
@IBOutlet weak var mapView: MKMapView!
    
    //setting the container for the data 
    var pin: Pin!
    var photos:Foto!
    //injecting the data source
    var dataController: DataController!
    //variable to store block operation for deleting photos from collectionView
    var blockOperation = BlockOperation()

    //
    var fetchedResultsController: NSFetchedResultsController<Foto>!

    var pageNumber = String((arc4random() % 3) + 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegates and data sources
        //collectionView.delegate = self
        //collectionView.dataSource = self
        
        //collectionView.allowsSelection = true
        //collectionView.isUserInteractionEnabled = true


        
        // makes the collection view looks nice with 3 columns
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2*space)) / 3.0
        
        flowLayout.minimumLineSpacing = space
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        // Do any additional setup after loading the view.
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        // do this later to add the hold touch to delete picture
       
        
    
        
        settingUpOriginalLocation()
        settiUpFetchResults()
        
        
        if let count = fetchedResultsController.fetchedObjects?.count {
            if count == 0 {
                //getting the URLS of the fotos
                print("I am here")
                NetworkRequests.getFotoLocation(url: NetworkRequests.Endpoints.getPictureOneMileRadius(String(pin.lat), String(pin.log), pageNumber).url) { (reponse, error) in
                //saving the data to a object
                    DataModel.photoArray = reponse
                    //downloading fotos and saving them
                    for index in DataModel.photoArray.indices {
                        
                        guard let URLForImage =  URL(string: DataModel.photoArray[index].url_sq) else {
                            return
                        }
                       
                        NetworkRequests.imageRequest(url: URLForImage, completionHandler: self.handleImageFileResponse(image:error:))
                    }
                }
                             
                
            } else {
                collectionView.reloadData()
            }
        }
        
    }
    
    func handleImageFileResponse(image: Data?, error: Error?) {
        
        DispatchQueue.main.async {
            
            let foto = Foto(context: self.dataController.viewContext)
            foto.downloadDate = Date()
            foto.imageToUse = image
            foto.pin = self.pin
            
            //saving the data
            try? self.dataController.viewContext.save()
        }
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        DataModel.photoArray = []
    }
    @IBAction func loadPictures(_ sender: UIButton) {
        
        pageNumber = String((arc4random() % 3) + 1)
     
        if let count = fetchedResultsController.fetchedObjects?.count {
            print("when loading \(count)")
            if count == 0 {
                fetchDataAgain()
                collectionView.reloadData()
                
            } else {
                //delete images
                if let index = fetchedResultsController.fetchedObjects?.indices {
                         for i in index {
                             let indexPath = IndexPath(row: i, section: 0)
                             deleteFoto(at: indexPath)
                         }
                
                    NetworkRequests.getFotoLocation(url: NetworkRequests.Endpoints.getPictureOneMileRadius(String(pin.lat), String(pin.log), pageNumber).url) { (reponse, error) in
                    //saving the data to a object
                        DataModel.photoArray = reponse
                        //downloading fotos and saving them
                        for index in DataModel.photoArray.indices {
                            NetworkRequests.imageRequest(url: URL(string: DataModel.photoArray[index].url_sq)!) { (image, error) in

                                DispatchQueue.main.async { [self] in
                                    let foto = Foto(context: self.dataController.viewContext)
                                    foto.downloadDate = Date()
                                    foto.imageToUse = image
                                    foto.pin = self.pin
                                    //saving the data
                                    try? self.dataController.viewContext.save()
                                 //   self.fetchDataAgain()
                                 //   self.collectionView.reloadData()
                                }
                            }
                        }
                    }
                
                }
                
                    
                
            }
    }
 
    }
                
    func deleteFoto(at indexPath: IndexPath) {
        
        let fotoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(fotoToDelete)
        try? dataController.viewContext.save()
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
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     print("You have delete this picture!")
    
        let pictureToBeDeleted = fetchedResultsController.object(at: indexPath)
        
        dataController.viewContext.delete(pictureToBeDeleted)

    }
    
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }
     
   
    
    fileprivate func fetchDataAgain() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription )")
        }
    }
    
    
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
            cell.imageView?.image = UIImage(data: fetchedResultsController.object(at: indexPath).imageToUse!)
       
    
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

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    // methods to delete images by clicking on them.
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
     
        blockOperation = BlockOperation()
     
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    
        let sectionIndexSet = IndexSet(integer: sectionIndex)
   
        switch type {
    
        case .insert:

            blockOperation.addExecutionBlock {
    
                self.collectionView?.insertSections(sectionIndexSet)
    
            }
    
        case .delete:
    
            blockOperation.addExecutionBlock {
                    
                self.collectionView?.deleteSections(sectionIndexSet)
    
            }
    
        case .update:
    
            blockOperation.addExecutionBlock {
    
                self.collectionView?.reloadSections(sectionIndexSet)
    
            }
    
        case .move:
    
            assertionFailure()
    
            break
    
        @unknown default:
            fatalError()
        }
    
    }
  
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    
        switch type {
    
        case .insert:
    
            guard let newIndexPath = newIndexPath else { break }
   
            blockOperation.addExecutionBlock {
    
                self.collectionView?.insertItems(at: [newIndexPath])
    
            }
    
        case .delete:
    
            guard let indexPath = indexPath else { break }
    
            
    
            blockOperation.addExecutionBlock {
    
                self.collectionView?.deleteItems(at: [indexPath])
    
            }
    
        case .update:
    
            guard let indexPath = indexPath else { break }
    
            
    
            blockOperation.addExecutionBlock {
    
                self.collectionView?.reloadItems(at: [indexPath])
    
            }
    
        case .move:
    
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
   
            blockOperation.addExecutionBlock {
    
                self.collectionView?.moveItem(at: indexPath, to: newIndexPath)
    
            }
    
        @unknown default:
            fatalError()
        }
    
    }
  
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    
        collectionView?.performBatchUpdates({
    
            self.blockOperation.start()
    
            }, completion: nil)
    
    }
    
}
