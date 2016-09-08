//
//  AppDelegate.swift
//  READY
//
//  Created by Patrick Sheehan on 9/5/15.
//  Copyright (c) 2015 Siochain. All rights reserved.	

let TheAppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

import Foundation
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
//        Fabric.with([Crashlytics.self])
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        TheQuickBloxAPIInterface.initProcess()
        TheVideoCallManager.initProcess()

        UINavigationBar.appearance().barTintColor = Constants.Colors.Gold
        UINavigationBar.appearance().translucent = false
        UITabBar.appearance().barTintColor = Constants.Colors.Gold

        self.registerForPushNotifications(application)
        
        
        
        // See if we have the device token saved

        if let token = userDefaults.valueForKey("kDeviceTokenStr") as? String {
            print("Found user's device token in userDefaults: \(token)")
            TheGlobalPoolManager.deviceToken = token
        }
        
        
        if (loggedIn()) {
            print("User is already logged in, loading Main storyboard")
            self.presentMain()
        } else {
            print("User is NOT logged in, loading login screen")
            self.presentLogin()
        }
        
        window?.makeKeyAndVisible()
        return true
    }
    
    func loggedIn() -> Bool {
        
        return TheGlobalPoolManager.currentUser != nil
    }

    private func convertDeviceTokenToString(deviceToken:NSData) -> String {
        //  Convert binary Device Token to a String (and remove the <,> and white space charaters).
        var deviceTokenStr = deviceToken.description.stringByReplacingOccurrencesOfString(">", withString: "")
        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString("<", withString: "")
        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        // Our API returns token in all uppercase, regardless how it was originally sent.
        // To make the two consistent, I am uppercasing the token string here.
        deviceTokenStr = deviceTokenStr.uppercaseString
        return deviceTokenStr
    }

    func applicationDidBecomeActive(application: UIApplication) {
        if TheGlobalPoolManager.accessToken != "" {
            TheGlobalPoolManager.getMissingMessages(false)
        }
    }
    
    
    //Called if unable to register for APNS.
    
    func registerForPushNotifications(application: UIApplication) {
        // Notification registration
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let pushNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()

    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        //reveice remote notification for chat
        
        print("Received remote notification")
        let newMessage: Message = Message()
        
        if (userInfo["aps"]!["type"]) as! String == "chat" {
            newMessage.loadDictionaryFromPush(userInfo["aps"] as! NSDictionary)
        }
        
        if application.applicationState == .Active {
            //app is in foreground
            if TheGlobalPoolManager.curMessageViewCon != nil && TheGlobalPoolManager.opponentUser?.username == newMessage.username {
                TheGlobalPoolManager.curMessageViewCon?.showReceiveMessages(newMessage)
            } else {
                TheGlobalPoolManager.getMissingMessages(false)
            }
        } else {
            //app is in background
        }
    }
    
    func application(application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        //send this device token to server
        let deviceTokenStr = convertDeviceTokenToString(deviceToken)
        TheGlobalPoolManager.deviceToken = deviceTokenStr
        
        userDefaults.setValue(deviceTokenStr, forKey: "kDeviceTokenStr")
        
        
        print ("Registered for remote notifications. Device token = \(deviceTokenStr)")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Device token for push notifications: FAIL -- ")
    }
    
    func logoff() {
        TheVideoCallManager.chatLogout()

        TheQuickBloxAPIInterface.logout({ (response) -> Void in
            
            }, errBlock: { (response) -> Void in
                
        })
        
        TheGlobalPoolManager.currentUser = nil
        
        MyPasswordManager.clearCredentials()
        
        self.presentLogin()
        
    }
    
    func presentLogin() {
        let s = UIStoryboard(name: "Signup", bundle: nil)
        
        window?.rootViewController = s.instantiateInitialViewController()
    }
    
    func presentMain() {
        
        // Tab Bar
        let tabBar = UITabBarController()
        tabBar.tabBar.translucent = false
        
        let userType = TheGlobalPoolManager.currentUser?.type
        if userType == "student" {
            print("User signed in is a student")
            tabBar.viewControllers = [
                profileViewController(),
                chatsViewController(),
                assignmentsViewController(),
            ]
        }
        else if userType == "teacher" {
            print("User signed in is a teacher")
            tabBar.viewControllers = [
                profileViewController(),
                classroomViewController(),
                teachersViewController()
//                discoverTopicsViewController()
            ]
        }
        else {
            TheInterfaceManager.showLocalValidationError("Unexpected user type. Should be either 'teacher' or 'student'")
        }
        
        TheInterfaceManager.mainTabViewController = tabBar
        
        self.window?.rootViewController = tabBar
        self.window?.makeKeyAndVisible()
    }

    func discoverTopicsViewController() -> UIViewController {
        
        let storyboardId = "DiscoverNavController"
        let iconImage = "DiscoverIcon"
        let iconTitle = CustomStringLocalization.textForKey("Discover")
        
        let s = UIStoryboard(name: "Main", bundle: nil)
        let vc = s.instantiateViewControllerWithIdentifier(storyboardId)
        vc.tabBarItem = UITabBarItem(title: iconTitle, image: UIImage(named: iconImage)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: UIImage(named: iconImage))
        
        return vc
    }
    
    func teachersViewController() -> UIViewController {
        
        let storyboardId = "TeacherNavController"
        let iconImage = "TeachersIcon"
        let iconTitle = CustomStringLocalization.textForKey("Other_Teachers")
        
        let s = UIStoryboard(name: "Main", bundle: nil)
        let vc = s.instantiateViewControllerWithIdentifier(storyboardId)
        vc.tabBarItem = UITabBarItem(title: iconTitle, image: UIImage(named: iconImage)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: UIImage(named: iconImage))
        
        return vc
    }
    
    func chatsViewController() -> UIViewController {
        
        let storyboardId = "StudentNavController"
        let iconImage = "MessageIcon"
        let user = TheGlobalPoolManager.currentUser
        
        var iconTitle = CustomStringLocalization.textForKey("My_Students")
        if user?.type == "student" {
            iconTitle = CustomStringLocalization.textForKey("My_Classmates")
        }
        
        let s = UIStoryboard(name: "Main", bundle: nil)
        let vc = s.instantiateViewControllerWithIdentifier(storyboardId)
        vc.tabBarItem = UITabBarItem(title: iconTitle, image: UIImage(named: iconImage)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: UIImage(named: iconImage))
        
        return vc
    }
    
    func profileViewController() -> UIViewController {
        
        let storyboardId = "ProfileNavController"
        let iconImage = "ProfileIcon"
        let iconTitle = CustomStringLocalization.textForKey("Profile")
        
        let s = UIStoryboard(name: "Main", bundle: nil)
        let vc = s.instantiateViewControllerWithIdentifier(storyboardId)
        vc.tabBarItem = UITabBarItem(title: iconTitle, image: UIImage(named: iconImage)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: UIImage(named: iconImage))
        
        return vc
    }
    
    func classroomViewController() -> UIViewController {
        
        let storyboardId = "ClassroomNavController"
        let iconImage = "ClassroomIcon"
        let iconTitle = CustomStringLocalization.textForKey("My_Classes")
        
        let s = UIStoryboard(name: "Main", bundle: nil)
        let vc = s.instantiateViewControllerWithIdentifier(storyboardId)
        vc.tabBarItem = UITabBarItem(title: iconTitle, image: UIImage(named: iconImage)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: UIImage(named: iconImage))
        
        return vc
    }
    
    func assignmentsViewController() -> UIViewController {
        
        let storyboardId = "AssignmentsNavController"
        let iconImage = "AssignmentIcon"
        let iconTitle = CustomStringLocalization.textForKey("Assignments")
        
        let s = UIStoryboard(name: "Main", bundle: nil)
        let vc = s.instantiateViewControllerWithIdentifier(storyboardId)
        vc.tabBarItem = UITabBarItem(title: iconTitle, image: UIImage(named: iconImage)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: UIImage(named: iconImage))
        
        return vc
    }
}
