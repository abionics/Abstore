//
//  UIViewController+alert.swift
//  Abstore
//
//  Created by Abionics on 8/21/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import UIKit

extension UIViewController {
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
