//
//  HelperMethodForAlert.swift
//  virtualTourist
//
//  Created by Ramon Yepez on 6/30/21.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(alertText : String, alertMessage : String) {
    let alertVC = UIAlertController(title:alertText, message: alertMessage, preferredStyle: .alert)
    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    
    self.present(alertVC, animated: true)
}
    
    
    
}
