//
//  CreateAssignmentViewController.swift
//  READY
//
//  Created by Admin on 25/05/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import SwiftyJSON

class CreateAssignmentViewController: UIViewController, UITextFieldDelegate {
    
    var selectedDate = NSDate()
    var animated: Bool = false

    var selectedClassroom: Classroom? = nil
    
    var bViewMode: Bool = false
    var selectedAssignment: Assignment? = nil
    
    @IBOutlet weak var m_txtTitle: UITextField!
    @IBOutlet weak var m_txtDescription: UITextField!
    @IBOutlet weak var m_txtAttachmentLink: UITextField!
    
    @IBOutlet weak var m_btnDeadline: UIButton!
    @IBOutlet weak var m_btnCreate: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Create a Assignment"
        
        makeUserInterface()
    }
    
    func makeUserInterface() {
        self.m_txtTitle.delegate = self
        self.m_txtDescription.delegate = self
        self.m_txtAttachmentLink.delegate = self
        
        if (bViewMode) {
            self.title = selectedAssignment?.title
            
            self.m_txtTitle.enabled = false
            self.m_txtAttachmentLink.enabled = false
            self.m_txtDescription.enabled = false
            self.m_btnDeadline.enabled = false
            
            self.m_txtTitle.text = selectedAssignment?.title
            self.m_txtDescription.text = selectedAssignment?.descr
            self.m_txtAttachmentLink.text = selectedAssignment?.link
            self.m_btnDeadline.setTitle(selectedAssignment?.deadline, forState: .Normal)

            self.m_btnCreate.setTitle("Complete", forState: .Normal)
            if (selectedAssignment?.completed_by_student == "1" || selectedAssignment?.completed_by_teacher == "1") {
                self.m_btnCreate.setTitle("Completed", forState: .Normal)
                self.m_btnCreate.enabled = false
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.hideKeyboard()
    }
    
    func hideKeyboard() {
        self.m_txtDescription .resignFirstResponder()
        self.m_txtTitle.resignFirstResponder()
        self.m_txtAttachmentLink.resignFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreateClassroomViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreateClassroomViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.removeKeyboardView()
    }
    
    func removeKeyboardView() {
        let rectScreen = UIScreen.mainScreen().bounds
        
        if self.animated {
            UIView.animateWithDuration(0.3, animations: {() -> Void in
                self.view.frame = CGRectMake(0, 64, rectScreen.size.width, rectScreen.size.height - 64);
                }, completion: nil)
        }
        
        self.animated = false;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        let rectScreen = UIScreen.mainScreen().bounds
        
        if (textField == self.m_txtTitle) {
            UIView.animateWithDuration(0.3, animations: {() -> Void in
                self.view.frame = CGRectMake(0, -0, rectScreen.size.width, rectScreen.size.height - 64);
                }, completion: nil)
            
            self.animated = true;
        }
        
        if (textField == self.m_txtDescription) {
            UIView.animateWithDuration(0.3, animations: {() -> Void in
                self.view.frame = CGRectMake(0, -40, rectScreen.size.width, rectScreen.size.height - 64);
                }, completion: nil)
            
            self.animated = true;
        }

        if (textField == self.m_txtAttachmentLink) {
            UIView.animateWithDuration(0.3, animations: {() -> Void in
                self.view.frame = CGRectMake(0, -60, rectScreen.size.width, rectScreen.size.height - 64);
                }, completion: nil)
            
            self.animated = true;
        }

        return true
    }
    
    @IBAction func actionChangeDeadline(sender: AnyObject) {
        ActionSheetDatePicker.showPickerWithTitle("Deadline", datePickerMode: .Date, selectedDate: selectedDate, doneBlock: {
            picker, index, value in
            
            NSLog("selected")
            
            self.selectedDate = index as! NSDate
            self.m_btnDeadline.setTitle(self.selectedDate.covertToString(), forState: .Normal)
            
            }, cancelBlock: {ActionStringCancelBlock in return}, origin: sender as! UIView)
    }

    @IBAction func actionCreate(sender: AnyObject) {
        if (bViewMode) {
            //complete assignment
            completeAssignment()
        } else {
            if (self.m_txtTitle.text?.length == 0) {
                TheInterfaceManager.showLocalValidationError("Please input title")
                return
            }
            
            if (self.m_txtDescription.text?.length == 0) {
                TheInterfaceManager.showLocalValidationError("Please input description")
                return
            }
            
            if (self.m_txtAttachmentLink.text?.length == -1) {
                TheInterfaceManager.showLocalValidationError("Please input attachment link")
                return
            }
            
            hideKeyboard()
            
            createAssignment()
        }
    }
    
    func completeAssignment() {
        LoadingOverlay.shared.showOverlay(TheAppDelegate.window!.rootViewController!.view)
        
        let paramsDict: Dictionary<String, AnyObject> = [
            "assignment_id": (self.selectedAssignment?.id)!
        ]
        
        WebServiceAPI.postDataWithURL(Constants.APINames.CompleteAssignment, withoutHeader: false, params: paramsDict, completionBlock: {(request:NSURLRequest?, response:NSHTTPURLResponse?, json:AnyObject)->Void in
            LoadingOverlay.shared.hideOverlayView()
            
            let responseFromServer = JSON(json).dictionaryObject
            
            let bSuccess = responseFromServer!["success"] as! String
            if (bSuccess == "1") {
                let alertView = UIAlertView(title: "Ready", message: "Completed assignment successfully!", delegate: self, cancelButtonTitle: "OK")
                alertView.show()
            } else {
                TheInterfaceManager.showLocalValidationError(responseFromServer!["message"] as! String)
            }
            }, errBlock: {(errorString) -> Void in
                TheInterfaceManager.showLocalValidationError(errorString)
                LoadingOverlay.shared.hideOverlayView()
        })
    }
    
    func createAssignment() {
        LoadingOverlay.shared.showOverlay(TheAppDelegate.window!.rootViewController!.view)
        
        let paramsDict: Dictionary<String, AnyObject> = [
            "title": self.m_txtTitle.text!,
            "description": self.m_txtDescription.text!,
            "link": self.m_txtAttachmentLink.text!,
            "deadline": (self.m_btnDeadline.titleLabel?.text)! as String,
            "classroom_id": (self.selectedClassroom?.id)!
        ]
        
        WebServiceAPI.postDataWithURL(Constants.APINames.StartAssignment, withoutHeader: false, params: paramsDict, completionBlock: {(request:NSURLRequest?, response:NSHTTPURLResponse?, json:AnyObject)->Void in
            LoadingOverlay.shared.hideOverlayView()
            
            let responseFromServer = JSON(json).dictionaryObject
            
            let bSuccess = responseFromServer!["success"] as! String
            if (bSuccess == "1") {
                let alertView = UIAlertView(title: "Ready", message: "Created assignment successfully!", delegate: self, cancelButtonTitle: "OK")
                alertView.show()
            } else {
                TheInterfaceManager.showLocalValidationError(responseFromServer!["message"] as! String)
            }
            }, errBlock: {(errorString) -> Void in
                TheInterfaceManager.showLocalValidationError(errorString)
                LoadingOverlay.shared.hideOverlayView()
        })
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
