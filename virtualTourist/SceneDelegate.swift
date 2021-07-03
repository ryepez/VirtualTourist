//
//  SceneDelegate.swift
//  virtualTourist
//
//  Created by Ramon Yepez on 6/16/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    
    var window: UIWindow?

    let dataController = DataController(modelName: "VitualTourist")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        dataController.load()
        //passing the datacontroller to first view
        let navigationController = window?.rootViewController as! UINavigationController
        let traveLocationMapController = navigationController.topViewController as! TraveLocationMapController
        //this will inject the data to TraveLocationMapController
        traveLocationMapController.dataController = dataController
        
        
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

}

