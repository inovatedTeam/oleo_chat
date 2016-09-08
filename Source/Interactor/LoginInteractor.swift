//
//  LoginInteractor.swift
//  READY
//
//  Created by Patrick Sheehan on 12/3/15.
//  Copyright © 2015 Siochain. All rights reserved.
//

import Foundation


class LoginInteractor: NSObject {
    
    /*
				login takes three arguments.
    emailAddr (string) - the UTF format of the email input
    password (string) - the UTF format of the password input
    complete (function) - wrapper function to handle success or error
				
				Attempts login by calling login.php on server.
    Makes a call to the completion function for the LoginViewController.
				
				There are no return values, but the function is set with
    success or failure, and also an access type (none for error).
    */
    
    /*
    class func login(email: String, password: String, completion: (success: Bool, error: NSError?) -> Void) {
        
        if UserPreferencesInteractor.isDemoModeOn() {
            
            print("Demo Mode is On")
            completion(success: true, error: nil)
            
        }
        
        
        //POST to login script to check for username/address
        let request = NSMutableURLRequest(URL: NSURL(string:"")!)
        request.HTTPMethod = "POST"
        let postString = "username=" + username + "&password=" + password;
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //connect to server in session
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            //print errors
            if error != nil {
                print("An error occurred while attempting a login request: \(error?.localizedDescription)")
                completion(success: false, error: error)
            } else {
                //ensure proper response from server
                if let _ = (response as! NSHTTPURLResponse).statusCode as Int? {
                    do {
                        //fetch data as dictionary
                        if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as?NSDictionary{
                            let message = json["0"] as! String
                            //success
                            if(message == "Log in"){
                                
                                UserPreferencesInteractor.setUsername(username)
                            }
                        }
                    } catch {
                        //not a dictionary, must be error
                        let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        if(responseString!=="Username not found"){
                            completion(success:false, error:NSError(domain: "username", code: 1, userInfo: [:]))
                        } else if(responseString!=="Wrong password"){
                            completion(success:false, error:NSError(domain: "password", code: 1, userInfo: [:]))
                        } else {
                            completion(success:false, error:NSError(domain: "undefined", code: 1, userInfo: [:]))
                        }
                    }
                }
            }
        }
        task.resume()
        
        return
    }
    
    */
    
}
