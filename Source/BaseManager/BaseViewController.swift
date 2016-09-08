//
//  BaseViewController.swift
//  READY
//
//  Created by Patrick Sheehan on 11/3/15.
//  Copyright © 2015 Siochain. All rights reserved.
//
import UIKit

class BaseViewController: UIViewController {

    var previousViewController:BaseViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func appDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func presentMain() {
        let c = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Main") as! UINavigationController
        self.presentViewController(c, animated: true, completion: nil)
    }
    
    func regularBackButton() {
        let button = UIBarButtonItem(title:"Back", style:.Plain, target:nil, action:nil)
        button.tintColor = UIColor.whiteColor()        
        self.navigationItem.backBarButtonItem = button
    }
    
    func titleBackButton(title:String) {
        let button = UIBarButtonItem(title:title, style:.Plain, target:nil, action:nil)
        button.tintColor = UIColor.whiteColor()
        self.navigationItem.backBarButtonItem = button
    }
    
    func dismissLoading() {
        print("ERROR: dismissLoading was called but is disabled")
    }
    
    func showLoading(message:String) {
        print("ERROR: showLoading was called but is disabled")
    }
}