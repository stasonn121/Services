//
//  File.swift
//  Services
//
//  Created by user on 31.03.2020.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit

class Alert {
    static let instance = Alert()
    
    func showAlert(message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: "Error", message: message , preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}
