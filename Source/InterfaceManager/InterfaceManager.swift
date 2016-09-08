//
//  ConstantManager.swift
//  VideoChat
//
//  Created by Admin on 04/03/16.
//  Copyright © 2016 Andrei. All rights reserved.
//

import Foundation
import UIKit

let TheInterfaceManager = InterfaceManager.sharedInstance

extension UIImage {
    static func downloadedFrom(link link:String, completionHandler:((image: UIImage?) -> Void)) {
        guard
            let url = NSURL(string: link)
            else {return}
        
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
                let data = data where error == nil,
                let image = UIImage(data: data)
                else
            {
                completionHandler(image:UIImage(named: "profile-icon.png"))
                return
            }
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                completionHandler(image:image)
            }
        }).resume()
    }
}

extension UIImageView {
    func downloadedFrom(link link:String, contentMode mode: UIViewContentMode) {
        guard
            let url = NSURL(string: link)
            else {return}
        contentMode = mode
        let loadingActivity = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        loadingActivity.tag = 10
        loadingActivity.frame = self.bounds
        self.addSubview(loadingActivity)
        loadingActivity.startAnimating()
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
                let data = data where error == nil,
                let image = UIImage(data: data)
                else
                {
                    self.image = UIImage(named: "profile-icon.png")
                    loadingActivity.stopAnimating()
                    loadingActivity.removeFromSuperview()
                    return
                }
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                loadingActivity.stopAnimating()
                loadingActivity.removeFromSuperview()
                self.image = image
            }
        }).resume()
    }
}

extension String {
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
        let emailTest  = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self)
    }
}

let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate//Your app delegate class name.
extension UIApplication {
    class func topViewController(base: UIViewController? = appDelegate.window!.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

class InterfaceManager: NSObject, UIAlertViewDelegate {
    static let sharedInstance = InterfaceManager()
    var resultAlertView:UIAlertView?
    var appName:String = ""
    var mainTabViewController: UITabBarController? = nil
    
    let mainColor:UIColor = UIColor(red: 77.0/255.0, green: 181.0/255.0, blue: 219.0/255.0, alpha: 1.0)
    let borderColor:UIColor = UIColor(red: 151.0 / 255.0, green: 151.0 / 255.0, blue: 151.0 / 255.0, alpha: 1.0)
    let naviTintColor:UIColor = UIColor(red: 252.0/255.0, green: 110.0/255.0, blue: 81.0/255.0, alpha: 1.0)
    
    var noInterView:NoInternetView?

    override init() {
        super.init()
        let bundleInfoDict: NSDictionary = NSBundle.mainBundle().infoDictionary!
        appName = bundleInfoDict["CFBundleName"] as! String
    }
    
    func deviceHeight ()-> CGFloat{
        return UIScreen.mainScreen().bounds.size.height
    }
    
    func deviceWidth () -> CGFloat{
        return UIScreen.mainScreen().bounds.size.width
    }
    
    func showLocalValidationError(errorMessage:String)-> Void{
        if let _ = resultAlertView {
            
        } else {
            let title:String = "\(appName) Error"
            resultAlertView = UIAlertView(title: title, message: errorMessage, delegate: self, cancelButtonTitle: "OK")
            resultAlertView!.show()
        }
    }
    
    func showLocalValidationError(title:String, errorMessage:String)-> Void{
        if let _ = resultAlertView {
            
        } else {
            resultAlertView = UIAlertView(title: title, message: errorMessage, delegate: self, cancelButtonTitle: "OK")
            resultAlertView!.show()
        }
    }
    
    func showSuccessMessage (successMessage:String)-> Void{
        if let _ = resultAlertView {
            
        } else {
            resultAlertView = UIAlertView(title: appName as String, message: successMessage, delegate: self, cancelButtonTitle: "OK")
            resultAlertView!.show()
        }
    }
    
    //MARK: - Custom View
    func showNoInternetConnectionView() {
        if let noInterView = noInterView {
            noInterView.frame = CGRectMake(0, -70, TheInterfaceManager.deviceWidth(),70)
        } else {
            noInterView = NoInternetView(frame:CGRectMake(0, -70, TheInterfaceManager.deviceWidth(), 70))
        }
        
        TheAppDelegate.window?.addSubview(noInterView!)
        
        UIView.animateWithDuration(0.25) { () -> Void in
            self.noInterView!.frame = CGRectMake(0, 0, TheInterfaceManager.deviceWidth(),70)
            
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            
            dispatch_after(dispatchTime, dispatch_get_main_queue()) {
                self.hideNoInternetConnectionView()
            }
        }
    }
    
    func hideNoInternetConnectionView() {
        if let _ = noInterView {
        } else {
            noInterView = NoInternetView(frame:CGRectMake(0, 0, TheInterfaceManager.deviceWidth(), 70))
        }
        
        TheAppDelegate.window?.addSubview(noInterView!)
        
        UIView.animateWithDuration(0.25) { () -> Void in
            self.noInterView!.frame = CGRectMake(0, -70, TheInterfaceManager.deviceWidth(),70)
        }
    }

    //MARK: - Navigation Bar
    func setNavigationBarTransparentTo(navigationController:UINavigationController?) {
        if let navigationController = navigationController {
            let clearImage = InterfaceManager.imageWithColor(UIColor.clearColor())
            navigationController.navigationBar.setBackgroundImage(clearImage, forBarMetrics: UIBarMetrics.Default)
            navigationController.navigationBar.shadowImage = UIImage()
            navigationController.navigationBar.backgroundColor = UIColor.clearColor()
            navigationController.navigationBar.translucent = true
            navigationController.navigationBar.tintColor = UIColor.whiteColor()
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
            
            navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        }
    }
    
    func setNavigationBarWithTintColor(navigationController:UINavigationController?) {
        if let navigationController = navigationController {
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.lightGrayColor()
            shadow.shadowOffset = CGSizeMake(0, 0)
            navigationController.navigationBar.tintColor = UIColor.whiteColor()
            navigationController.navigationBar.barTintColor = naviTintColor
            navigationController.navigationBar.translucent = false
            navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        }
    }
    
     static func imageWithColor(color:UIColor) -> UIImage {
        let rect:CGRect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    static func makeRadiusControl(view:UIView, cornerRadius radius:CGFloat, withColor borderColor:UIColor, borderSize borderWidth:CGFloat) {
        view.layer.cornerRadius = radius
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.CGColor
        view.layer.masksToBounds = true
    }
    
    static func addBorderToView(view:UIView, toCorner corner:UIRectCorner, cornerRadius radius:CGSize, withColor borderColor:UIColor, borderSize borderWidth:CGFloat) {
        let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corner, cornerRadii: radius)
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path  = maskPath.CGPath
        
        view.layer.mask = maskLayer
        
        let borderLayer = CAShapeLayer()
        borderLayer.frame = view.bounds
        borderLayer.path  = maskPath.CGPath
        borderLayer.lineWidth   = borderWidth
        borderLayer.strokeColor = borderColor.CGColor
        borderLayer.fillColor   = UIColor.clearColor().CGColor
        borderLayer.setValue("border", forKey: "name")
        
        if let sublayers = view.layer.sublayers {
            for prevLayer in sublayers {
                if let name: AnyObject = prevLayer.valueForKey("name") {
                    if name as! String == "border" {
                        prevLayer.removeFromSuperlayer()
                    }
                }
            }
        }
        
        view.layer.addSublayer(borderLayer)
    }
    
    //MARK: UIAlertViewDelegate
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        resultAlertView = nil
    }
    
    // MARK: - Others
    func sizeOfString (string: String, constrainedToWidth width: Double, font:UIFont) -> CGSize {
        return NSString(string: string).boundingRectWithSize(CGSize(width: width, height: DBL_MAX),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: font],
            context: nil).size
    }
    
}