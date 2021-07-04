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
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var newColletionButton: UIButton!
    
    //setting the container for the data
    var pin: Pin!
    //injecting the data source
    var dataController: DataController!
    //variable to store block operation for deleting photos from collectionView
    var blockOperation = BlockOperation()
    
    // the fectch results
    var fetchedResultsController: NSFetchedResultsController<Foto>!
    
    //variable to store random number
    var pageNumber = String((arc4random() % 3) + 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // makes the collection view looks nice with 3 columns
        
        makeCollectionViewThreeColumns()
        
        //hide navigation bar
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        //getting last location on map
        settingUpOriginalLocation()
        //getting data from coreData
        settiUpFetchResults()
        
        //check the content of coreData and response accordingly
        if let count = fetchedResultsController.fetchedObjects?.count {
            if count == 0 {
                gettingImagesToLoad()
            }
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DataModel.photoArray = []
    }
    
    
    fileprivate func makeCollectionViewThreeColumns() {
        // makes the collection view looks nice with 3 columns
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2*space)) / 3.0
        
        flowLayout.minimumLineSpacing = space
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    fileprivate func gettingImagesToLoad() {
        
        //make activity animation to true
        setLoggion(true)
        
        //requesting the URLs of the image of one mile radius of these lat and log.
        NetworkRequests.getFotoLocation(url: NetworkRequests.Endpoints.getPictureOneMileRadius(String(pin.lat), String(pin.log), pageNumber).url) { [weak self] (reponse, error) in
            
            
            guard let strongSelf = self else { return }
            
            if reponse.count != 0 {
                
                //saving the data to a object
                DataModel.photoArray = reponse
                
                //loop to create objects that will hold the image
                for photo in DataModel.photoArray {
                    //cereating a pin with no picture
                    strongSelf.handleImageFile(urlForImage: photo.url_sq)
                }
                
                //make activity animation to false
                strongSelf.setLoggion(false)
                
            } else {
                //make activity animation to false
                strongSelf.showAlert(alertText: "No images for this location", alertMessage: "Please select a new location")
                strongSelf.setLoggion(false)
            }
            
        }
    }
    
    func handleImageFile(urlForImage: String) {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let strongSelf = self else { return }
            
            let foto = Foto(context: strongSelf.dataController.viewContext)
            foto.url = urlForImage
            foto.downloadDate = Date()
            foto.pin = strongSelf.pin
            foto.imageToUse = nil
            
            //saving the data
            
            do {
                try strongSelf.dataController.viewContext.save()
            } catch {
                strongSelf.showAlert(alertText: "Data could not be save", alertMessage: "Please try again.")
            }
            
        }
        
    }
    
    
    
    @IBAction func loadPictures(_ sender: UIButton) {
        
        pageNumber = String((arc4random() % 3) + 1)
        
        if let count = fetchedResultsController.fetchedObjects?.count {
            print("when loading \(count)")
            if count == 0 {
                //when there are not images we show a alert message
                self.showAlert(alertText: "No images for this location", alertMessage: "Please select a new location")
                
            } else {
                
                //1) delete images
                
                if let objectToDelete = fetchedResultsController.fetchedObjects {
                    for index in objectToDelete {
                        dataController.viewContext.delete(index)
                        do {
                            try dataController.viewContext.save()
                        } catch {
                            showAlert(alertText: "Data could not be save", alertMessage: "Please try again.")
                        }
                    }
                    // 2) load new images
                    
                    gettingImagesToLoad()
                    
                }
                
                
                
            }
        }
        
    }
    
    
    // Method to show the activity indicatior
    
    func setLoggion(_ logingIP: Bool) {
        
        if logingIP {
            activityIndicator.startAnimating()
            newColletionButton.isEnabled = !logingIP
            
        } else {
            activityIndicator.stopAnimating()
            newColletionButton.isEnabled = true
            
        }
        
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
    
    
    fileprivate func fetchDataAgain() {
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
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        cell.imageView.image = UIImage(named: "placeHolder")
        
        let photo = self.fetchedResultsController.object(at: indexPath)
        let photoURLString = photo.url
        let photoURL = URL(string: photoURLString ?? "")
        
        
        if
            photo.imageToUse == nil,
            let photoURL = photoURL
        
        {
            //sending the download on pictures to the a new background trend
            DispatchQueue.global(qos: .background).async { [weak self, photoURL]  in
                
                NetworkRequests.imageRequest(url: photoURL) { (data, error) in
                    
                    DispatchQueue.main.async {
                        photo.imageToUse = data
                        
                        try? self?.dataController.viewContext.save()
                        
                        if let data = data {
                            let uImage = UIImage(data: data)
                            cell.imageView.image = uImage
                        }
                        
                    }
                    
                }
            }
        }
        else {
            if let image = photo.imageToUse {
                let uiImage = UIImage(data: image)
                cell.imageView?.image = uiImage
            }
        }
        
        
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
            
            blockOperation.addExecutionBlock { [weak self] in
                
                self?.collectionView?.insertSections(sectionIndexSet)
                
            }
            
        case .delete:
            
            blockOperation.addExecutionBlock { [weak self] in
                
                self?.collectionView?.deleteSections(sectionIndexSet)
                
            }
            
        case .update:
            
            blockOperation.addExecutionBlock { [weak self] in
                
                self?.collectionView?.reloadSections(sectionIndexSet)
                
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
            
            blockOperation.addExecutionBlock { [weak self] in
                
                self?.collectionView?.insertItems(at: [newIndexPath])
                
            }
            
        case .delete:
            
            guard let indexPath = indexPath else { break }
            
            
            
            blockOperation.addExecutionBlock { [weak self] in
                
                self?.collectionView?.deleteItems(at: [indexPath])
                
                
            }
            
            
        case .move:
            
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            
            blockOperation.addExecutionBlock { [weak self] in
                
                self?.collectionView?.moveItem(at: indexPath, to: newIndexPath)
                
            }
            
        @unknown default: break
            
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView?.performBatchUpdates({ [weak self] in
            
            self?.blockOperation.start()
            
        }, completion: nil)
        
    }
    
}
