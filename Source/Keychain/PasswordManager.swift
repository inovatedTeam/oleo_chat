//
//  PasswordManager.swift
//  ready
//
//  Created by Patrick Sheehan on 8/18/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import Foundation

let MyPasswordManager = PasswordManager()

class PasswordManager: NSObject {
    
    let MyKeychainWrapper = KeychainWrapper()

    func storeCredentials(username: String, password: String) {
        
        print("Begin storing credentials for username: \(username) & password: \(password)")
        
        // save username in user defaults
        NSUserDefaults.standardUserDefaults().setValue(username, forKey: "username")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasLoginKey")
        NSUserDefaults.standardUserDefaults().synchronize()

        // save password to keychain
        MyKeychainWrapper.mySetObject(password, forKey:kSecValueData)
        MyKeychainWrapper.writeToKeychain()

    }
    
    func retrieveCredentials() -> (username: String, password: String)? {
        if NSUserDefaults.standardUserDefaults().boolForKey("hasLoginKey") == true {

            if let password = MyKeychainWrapper.myObjectForKey("v_Data") as? String,
                let username = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String {
                return (username, password)
            }
        }
        
        return nil
    }
    
    func clearCredentials() {
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "username")
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "hasLoginKey")
        NSUserDefaults.standardUserDefaults().synchronize()
        

    }
    
}
