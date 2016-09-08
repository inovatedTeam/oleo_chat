//
//  UserInteractor.swift
//  ready
//
//  Created by Patrick Sheehan on 1/16/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit

let userDefaults = NSUserDefaults.standardUserDefaults()

class UserInteractor {
    
    class func setProfilePic(image: UIImage) {
        userDefaults.setObject(UIImagePNGRepresentation(image), forKey: "profilePic")
    }
    
    class func getProfilePic() -> UIImage? {

        if let imgData = userDefaults.objectForKey("profilePic") as? NSData {
            let image = UIImage(data: imgData)
            return image
        }
        return UIImage(named: "user.png")
    }
    
    
    // MARK: - Current User
    class func setUser(user:User?) {
        if (user == nil) {
            userDefaults.setObject(nil, forKey: "user")
        } else {
            userDefaults.setObject(user!.toH(), forKey: "user")
        }
    }
    
    class func getUser() -> User? {
        if let userData = userDefaults.dictionaryForKey("user") as NSDictionary? {

            let user = User()
            user.loadDictionary(userData)
            
            user.profilePic = getProfilePic()
            
            return user
        }
        return nil
    }
    
    // MARK: - Login / Registration
    class func login(username: String, password: String, completion: (success: Bool, error: NSError?) -> Void) {
        
        print("Force allowing login for \(username) with English as native language")
        
        let user = User()
        user.username = username
        user.nativeLanguage = .English
        
        self.setUser(user)
        
        completion(success: true, error: nil)
    }

    class func register(user:User, completion: (success: Bool, error: NSError?) -> Void) {
        print("Signing up a new User. Eventually this will talk to a server and wait for a confirmation. For now, setting this user as the current one")
        
        if user.password != user.passwordConfirmation {
            completion(success: false, error: NSError(domain: "Passwords do not match", code: 400, userInfo: nil))
        }
        else {
            self.setUser(user)
            completion(success: true, error: nil)
        }
    }

    class func logoff() {
        print("Logging off user")
        self.setUser(nil)
    }
}