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
    
    var backgroundContext:NSManagedObjectContext!
    
    func configureContexts() {
        //private quele
        backgroundContext = persistentContainer.newBackgroundContext()
        
        //merge changes
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        //in cases of a merger config the object's data will be the one that will previl
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        //for the view context the data on the database will previl
        
        viewContext.mergePolicy =  NSMergePolicy.mergeByPropertyStoreTrump
        
    }
    //function load the data from the container
    
    func load(completion: (() -> Void)? = nil)  {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
           //chekign that we do not have an error
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext(interval: 3)
            self.configureContexts()
            completion?()
        }

    }
}

extension DataController {
    
    func autoSaveViewContext(interval: TimeInterval = 30) {
        print("autosaving")
        guard interval > 0 else {
            print("cannot set negative auto interval")
            return
        }
        // check to see if there were changes.
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
