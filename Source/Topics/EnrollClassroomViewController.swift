//
//  EnrollClassroomViewController.swift
//  ready
//
//  Created by Patrick Sheehan on 8/21/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit
import SwiftyJSON

class EnrollClassroomViewController: UIViewController {

    @IBOutlet var textField: UITextField!
    
    @IBAction func cancel(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submit(sender: AnyObject) {
        
        if let pin = textField.text {
            
            self.enrollInClass(pin)
            
        }
    }
    
    func enrollInClass(pin: String) {
        
        let user_id = TheGlobalPoolManager.currentUser?.id

        let paramsDict: Dictionary<String, AnyObject> = [
            "user_id": user_id!,
            "pin": pin
        ]
        
        LoadingOverlay.shared.showOverlay(self.view)
        WebServiceAPI.postDataWithURL(Constants.APINames.EnrollClassroomWithPin, withoutHeader: true, params: paramsDict, completionBlock: { (request, response, json) in
            print("Successfully enrolled")
            LoadingOverlay.shared.hideOverlayView()
            self.dismissViewControllerAnimated(true, completion: nil)
            }) { (errorString) in
                print("Failed to enroll")
                LoadingOverlay.shared.hideOverlayView()
                TheInterfaceManager.showLocalValidationError(errorString)
        }
        
    }
}
