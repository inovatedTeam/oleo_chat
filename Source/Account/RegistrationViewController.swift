//
//  RegistrationViewController.swift
//  ready
//
//  Created by Patrick Sheehan on 1/13/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class RegistrationViewController: BaseViewController {

    // MARK: - IB Outlets
    @IBOutlet var usernameField:UITextField!
    @IBOutlet var emailField:UITextField!
    @IBOutlet var passwordField:UITextField!
    @IBOutlet var passwordConfirmationField:UITextField!
    @IBOutlet var registrationButton:UIButton!
    @IBOutlet var loginButton:UIButton?
    @IBOutlet var nativeLanguageButton: UIButton!
    @IBOutlet var userTypeSegControl: UISegmentedControl!
    
    // MARK: - Member Variables
    var registerDelegate: FinishedRegisteringDelegate?
    var nativeLanguage: Language = .English

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        passwordConfirmationField.delegate = self
        
        let randInt = Int(arc4random_uniform(100) + 1)

        usernameField.text = "student\(randInt)"
        emailField.text = "student\(randInt)@email.com"
        passwordField.text = "password"
        passwordConfirmationField.text = "password"

    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.hideKeyboard()
    }

    // MARK: - IB Actions
    @IBAction func register() {
        self.hideKeyboard()
        
        if self.validateInput() {
        
            let type = self.userTypeSegControl.selectedSegmentIndex == 0 ? "student" : "teacher"
            print("Attempt registration as a \(type)")
            
            if let username = self.usernameField.text,
                let email = self.emailField.text,
                let password = self.passwordField.text,
                let passwordConf = self.passwordConfirmationField.text {
                
                LoadingOverlay.shared.showOverlay(self.view)

                // Check QuickBlox to see if this account already exists
                TheQuickBloxAPIInterface.checkExsitingAccount(email, completionBlock: { (bSuccess, userID) -> Void in
                    if (bSuccess) {
                        print("QuickBlox already has this account, begin signUpRequest for our app")
                        self.signUpRequest(username, email: email, password: password, passwordConf: passwordConf, type: type, QuickbloxID: userID!)
                    } else {
                        print("QuickBlox did not have this account yet, begin signUp with them")
                        TheQuickBloxAPIInterface.signup(username, email: email, password: password, fullname: username, completionBlock: { (response, user) -> Void in
                            
                            print("Finished sign up with QuickBlox with response: \(response) and user: \(user)")
                            print("Begin signUpRequest with our app")
                            self.signUpRequest(username, email: email, password: password, passwordConf: passwordConf, type: type, QuickbloxID: (user?.ID)!)
                            }, errBlock: { (response) -> Void in
                                print("ERROR: An error occurred while signing up with QuickBlox")
                                LoadingOverlay.shared.hideOverlayView()
                        })
                    }
                })
            }
        }
    }
    
    @IBAction func selectNativeLanguage(sender: UIButton) {
        
        ActionSheetStringPicker.showPickerWithTitle(CustomStringLocalization.textForKey("Language"), rows: Language.allLanguages(), initialSelection:self.nativeLanguage.rawValue, doneBlock: {
            picker, value, index in
            
            self.nativeLanguage = Language(rawValue: value)!
            self.nativeLanguageButton.setTitle("\(CustomStringLocalization.textForKey("Native_Language")): \(self.nativeLanguage)", forState: .Normal)
            return
            }, cancelBlock: { ActionStringCancelBlock in return },
               origin: sender)
        
        
    }
    
    @IBAction func goToLogin() {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Helper Methods
    func signUpRequest(username: String, email: String, password: String, passwordConf: String, type: String, QuickbloxID: UInt) {
        print ("Registering for our app with username: \(username)")
        
        let user = User()
        user.username = username
        user.email = email
        user.password = password
        user.passwordConfirmation = passwordConf
        user.nativeLanguage = self.nativeLanguage
        user.type = type
        user.QuickbloxID = QuickbloxID
        
        WebServiceAPI.postDataWithURL(Constants.APINames.SignUp, withoutHeader: true, params: user.toH() as? Dictionary<String, AnyObject>, completionBlock: {(request:NSURLRequest?, response:NSHTTPURLResponse?, json:AnyObject)->Void in
            
            print("Registration with our app succeeded. Pop this navigation controller, and now try to automatically login")
            self.registerDelegate?.didFinishRegistering(user.username, password: user.password)
            LoadingOverlay.shared.hideOverlayView()
            
            }, errBlock: {(errorString) -> Void in
                LoadingOverlay.shared.hideOverlayView()
        })
    }
    
    func hideKeyboard() {
        self.usernameField.resignFirstResponder()
        self.emailField.resignFirstResponder()
        self.passwordField.resignFirstResponder()
        self.passwordConfirmationField.resignFirstResponder()
    }
    
    func validateInput() -> Bool {
        if self.usernameField.text?.length == 0 {
            TheInterfaceManager.showLocalValidationError("Error", errorMessage: "Please input username!")
            return false
        }
        
        if self.emailField.text?.length == 0  {
            TheInterfaceManager.showLocalValidationError("Error", errorMessage: "Please input email address!")
            return false
        }
        
        if self.emailField.text?.isEmail == false {
            TheInterfaceManager.showLocalValidationError("Error", errorMessage: "Please input correct email address!")
            return false
        }
        
        if self.passwordField.text?.length == 0  {
            TheInterfaceManager.showLocalValidationError("Error", errorMessage: "Please input password!")
            return false
        }
        
        if self.passwordField.text?.length < 8  {
            TheInterfaceManager.showLocalValidationError("Error", errorMessage: "Password length should be 8 characters as minimum!")
            return false
        }
        
        if self.passwordConfirmationField.text?.length == 0  {
            TheInterfaceManager.showLocalValidationError("Error", errorMessage: "Please confirm password!")
            return false
        }
        
        if self.passwordField.text != self.passwordConfirmationField.text {
            TheInterfaceManager.showLocalValidationError("Error", errorMessage: "Please confirm password correctly!")
            return false
        }
        
        
        return true
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    
    // MARK: - Text Field Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.text!.isEmpty {
            return false
        }
        
        textField.resignFirstResponder()

        if textField == usernameField {
            emailField?.becomeFirstResponder()
        }
        else if textField == emailField {
            passwordField?.becomeFirstResponder()
        }
        else if textField == passwordField {
            passwordConfirmationField?.becomeFirstResponder()
        }
        else if textField == passwordConfirmationField {
            selectNativeLanguage(self.nativeLanguageButton)
        }
        
        return true
    }
}
