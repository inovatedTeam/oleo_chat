//
//  CreateClassroomViewController.swift
//  READY
//
//  Created by Admin on 25/05/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import SwiftyJSON

class CreateClassroomViewController: UIViewController {
    
    // MARK: - Member Variables
    var selectedLanguage: Language? = nil
    var animated: Bool = false

    // MARK: - IB Outlets
    @IBOutlet weak var m_txtTitle: UITextField!
    @IBOutlet weak var m_txtSubTitle: UITextField!
    @IBOutlet weak var m_btnLanguage: UIButton!
    @IBOutlet weak var m_btnCreate: UIButton!
    
    // MARK: - IB Actions
    @IBAction func actionChangeLanguage(sender: AnyObject) {
        if selectedLanguage == nil {
            selectedLanguage = .English
        }
        
        ActionSheetStringPicker.showPickerWithTitle(CustomStringLocalization.textForKey("Language"), rows: Language.allLanguages(), initialSelection:selectedLanguage!.rawValue, doneBlock: {
            picker, value, index in
            
            let targetLanguage = Language(rawValue: value)!
            print("User changed target language to: \(targetLanguage)")
            
            self.m_btnLanguage.setTitle(index as? String, forState: .Normal)
            self.selectedLanguage = Language(rawValue: value)
            
            return
            }, cancelBlock: { ActionStringCancelBlock in return },
               origin: sender)
    }
    
    @IBAction func actionCreate(sender: AnyObject) {
        if (self.m_txtTitle.text?.length == 0) {
            TheInterfaceManager.showLocalValidationError("Please input title")
            return
        }
        
        if (self.m_txtSubTitle.text?.length == 0) {
            TheInterfaceManager.showLocalValidationError("Please input title")
            return
        }
        
        if (selectedLanguage == nil) {
            TheInterfaceManager.showLocalValidationError("Please choose language")
            return
        }
        
        hideKeyboard()
        
        LoadingOverlay.shared.showOverlay(TheAppDelegate.window!.rootViewController!.view)
        
        let paramsDict: Dictionary<String, AnyObject> = [
            "title": self.m_txtTitle.text!,
            "subtitle": self.m_txtSubTitle.text!,
            "lang": selectedLanguage!.code
        ]
        
        WebServiceAPI.postDataWithURL(Constants.APINames.CreateClassroom, withoutHeader: false, params: paramsDict, completionBlock: {(request:NSURLRequest?, response:NSHTTPURLResponse?, json:AnyObject)->Void in
            LoadingOverlay.shared.hideOverlayView()
            
            let responseFromServer = JSON(json).dictionaryObject
            
            let bSuccess = responseFromServer!["success"] as! String
            if (bSuccess == "1") {
                let alertView = UIAlertView(title: "Ready", message: "Created classroom successfully!", delegate: self, cancelButtonTitle: "OK")
                alertView.show()
            } else {
                TheInterfaceManager.showLocalValidationError(responseFromServer!["message"] as! String)
            }
            }, errBlock: {(errorString) -> Void in
                TheInterfaceManager.showLocalValidationError(errorString)
                LoadingOverlay.shared.hideOverlayView()
        })
        
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Create a Classroom"
        
        self.m_txtTitle.delegate = self
        self.m_txtSubTitle.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreateClassroomViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreateClassroomViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.hideKeyboard()
    }
    
    // MARK: - Keyboard Methods
    func keyboardWillShow(notification: NSNotification) {
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.removeKeyboardView()
    }
    
    private func hideKeyboard() {
        self.m_txtSubTitle.resignFirstResponder()
        self.m_txtTitle.resignFirstResponder()
    }
    
    private func removeKeyboardView() {
        let rectScreen = UIScreen.mainScreen().bounds
        
        if self.animated {
            UIView.animateWithDuration(0.3, animations: {() -> Void in
                self.view.frame = CGRectMake(0, 64, rectScreen.size.width, rectScreen.size.height - 64);
                }, completion: nil)
        }
        
        self.animated = false;
    }
}

extension CreateClassroomViewController: UITextFieldDelegate {
    // MARK: - Text Field Methods
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        let rectScreen = UIScreen.mainScreen().bounds
        
        if (textField == self.m_txtTitle) {
            UIView.animateWithDuration(0.3, animations: {() -> Void in
                self.view.frame = CGRectMake(0, -0, rectScreen.size.width, rectScreen.size.height - 64);
                }, completion: nil)
            
            self.animated = true;
        }
        
        if (textField == self.m_txtSubTitle) {
            UIView.animateWithDuration(0.3, animations: {() -> Void in
                self.view.frame = CGRectMake(0, -40, rectScreen.size.width, rectScreen.size.height - 64);
                }, completion: nil)
            
            self.animated = true;
        }
        
        return true
    }
}

extension CreateClassroomViewController: UIAlertViewDelegate {
    // MARK: - Alert View Methods
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
