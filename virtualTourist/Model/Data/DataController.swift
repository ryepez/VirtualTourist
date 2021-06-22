//
//  DataController.swift
//  virtualTourist
//
//  Created by Ramon Yepez on 6/21/21.
//

import Foundation
import CoreData

class DataController {
 

    // access the context 
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    //first we need to set the class to hold a persitance container
    let persistentContainer: NSPersistentContainer
    //initializing the class to take a model name for the holder
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    //function load the data from the container
    
    func load(completion: (() -> Void)? = nil)  {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
           //chekign that we do not have an error
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }

    }
}
