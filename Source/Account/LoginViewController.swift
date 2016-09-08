//
//  LoginViewController.swift
//  READY
//
//  Created by Patrick Sheehan on 9/8/15.
//  Copyright (c) 2015 Siochain. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol FinishedRegisteringDelegate {
    func didFinishRegistering(username: String, password: String)
}

class LoginViewController: BaseViewController {
    
    // MARK: - IB Outlets
    @IBOutlet var usernameField:UITextField!
    @IBOutlet var passwordField:UITextField!
    @IBOutlet var loginButton:UIButton!
    @IBOutlet var signupButton:UIButton!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.usernameField.delegate = self
        self.passwordField.delegate = self
       
        if let credentials = MyPasswordManager.retrieveCredentials() {
            print("PasswordManager retrieved credentials, filling in fields now.")
            print("username: \(credentials.username) password:\(credentials.password)")
            self.usernameField.text = credentials.username
            self.passwordField.text = credentials.password
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
  
        if !(self.usernameField.text?.isEmpty)! && !(self.passwordField.text?.isEmpty)! {
            print("LoginVC had credentials provided, perform login now")
            self.login()
        }
        
//        self.usernameField.becomeFirstResponder()
        
//        self.usernameField.text = "student"
//        self.passwordField.text = "password"
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.hideKeyboard()
    }
    
    // MARK: - IB Actions
    @IBAction func login() {
        self.hideKeyboard()
        
        if self.usernameField.text?.length == 0 {
            TheInterfaceManager.showLocalValidationError("Error", errorMessage: "Please input username!")
            return
        }
        
        if self.passwordField.text?.length == 0  {
            TheInterfaceManager.showLocalValidationError("Error", errorMessage: "Please input password!")
            return
        }
        
        if self.passwordField.text?.length < 8  {
            TheInterfaceManager.showLocalValidationError("Error", errorMessage: "Password length should be 8 characters as minimum!")
            return
        }
        
        let username = self.usernameField.text!
        let password = self.passwordField.text!
        
        let paramsDict: Dictionary<String, AnyObject> = [
            "userName": username,
            "password": password,
            "device_id": TheGlobalPoolManager.deviceToken,
            "device_type": Constants.DeviceInfo.DeviceType
        ]
        
        print("Login params: \(paramsDict)")
        LoadingOverlay.shared.showOverlay(self.view)
        
        WebServiceAPI.postDataWithURL(Constants.APINames.Login, withoutHeader: true, params: paramsDict, completionBlock: {(request:NSURLRequest?, response:NSHTTPURLResponse?, json:AnyObject)->Void in
            print("Successfully logged in")
            
            let responseFromServer = JSON(json).dictionaryObject
            TheGlobalPoolManager.accessToken = responseFromServer!["Access-Token"] as! String
            TheGlobalPoolManager.currentUser = User()
            TheGlobalPoolManager.currentUser?.loadDictionary(responseFromServer!["userInfo"] as! Dictionary<String, AnyObject>)
            
            //quickblox login
            TheQuickBloxAPIInterface.login("\(TheGlobalPoolManager.currentUser!.QuickbloxID))", email: TheGlobalPoolManager.currentUser!.email, password: password, completionBlock: { (response, user) -> Void in
                //video call login
                user?.password = password
                
                TheVideoCallManager.chatLoginWithUser(user!, completionError: { (bSuccess, error) -> Void in
                    
                    if (bSuccess) {
                        
                        print("Storing credentials in PasswordManager")
                        MyPasswordManager.storeCredentials(username, password: password)
                        
                        LoadingOverlay.shared.hideOverlayView()
                        
                        self.appDelegate().presentMain()
                    } else {
                        LoadingOverlay.shared.hideOverlayView()
                        
                        TheInterfaceManager.showLocalValidationError((error?.description)!)
                    }
                })
                
                }, errBlock: { (response) -> Void in
                    LoadingOverlay.shared.hideOverlayView()
                    
                    TheInterfaceManager.showLocalValidationError((response.error?.description)!)
            })
            }, errBlock: {(errorString) -> Void in
                TheInterfaceManager.showLocalValidationError(errorString)
                LoadingOverlay.shared.hideOverlayView()
        })
    }
    
    @IBAction func goToSignUp() {
        
        let registrationVC = self.storyboard?.instantiateViewControllerWithIdentifier("RegistrationViewController") as! RegistrationViewController
        registrationVC.registerDelegate = self
        self.navigationController?.pushViewController(registrationVC, animated: true)
    }
    
    // MARK: - Helper Methods
    func hideKeyboard() {
        self.usernameField.resignFirstResponder()
        self.passwordField.resignFirstResponder()
    }
}

extension LoginViewController: UITextFieldDelegate {

    // MARK: - Text Field Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.text!.isEmpty {
            return false
        }
        
        textField.resignFirstResponder()
        
        if textField == usernameField {
            passwordField?.becomeFirstResponder()
        }
        else if textField == passwordField {
            login()
        }
        
        return true
    }
    
}

extension LoginViewController: FinishedRegisteringDelegate {
    
    func didFinishRegistering(username: String, password: String) {
        
        self.usernameField.text = username
        self.passwordField.text = password
        self.login()
    }
}