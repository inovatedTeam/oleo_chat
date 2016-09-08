//
//  FeedbackViewController.swift
//  READY
//
//  Created by Admin on 06/03/16.
//  Copyright © 2016 Andrei. All rights reserved.
//

import UIKit

let descriptionPlaceHolder = "Conversation Feedback"
let gradePlaceHolder = "Conversation Grade"

class FeedbackViewController: UIViewController {

    // MARK: - IB Outlets
    @IBOutlet weak var m_txtViewDescription: UITextView!
    @IBOutlet weak var m_txtGrade: PaddingTextField!
    @IBOutlet weak var m_btnSubmit: UIButton!
    
    // MARK: - Member variables
    var animated: Bool = false
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Feedback"
        
        self.m_txtViewDescription.text = descriptionPlaceHolder
        self.m_txtViewDescription.textColor = UIColor.lightGrayColor()
        
        self.m_txtGrade.text = gradePlaceHolder
        
        if let user = TheGlobalPoolManager.currentUser {
            
            if user.type == "teacher" {
                
                self.m_txtViewDescription.editable = true
                self.m_txtGrade.enabled = true
                self.m_btnSubmit.enabled = true
                
            } else if user.type == "student" {
                
                self.m_txtViewDescription.editable = false
                self.m_txtGrade.enabled = false
                self.m_btnSubmit.enabled = false
            }
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        InterfaceManager.addBorderToView(self.m_txtViewDescription, toCorner: .AllCorners, cornerRadius: CGSizeMake(3.0, 3.0), withColor: UIColor.darkGrayColor(), borderSize: 2.0)
        InterfaceManager.addBorderToView(self.m_txtGrade, toCorner: .AllCorners, cornerRadius: CGSizeMake(3.0, 3.0), withColor: UIColor.darkGrayColor(), borderSize: 2.0)
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedbackViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedbackViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.hideKeyboard()
    }
    
    // MARK: - IB Actions
    @IBAction func actionSubmitFeedback(sender: AnyObject) {
        if self.m_txtViewDescription.text.length == 0 || self.m_txtViewDescription.text == descriptionPlaceHolder {
            TheInterfaceManager.showLocalValidationError("Error", errorMessage: "Please input description")
            return
        }
        
        if self.m_txtGrade.text!.length == 0 {
            TheInterfaceManager.showLocalValidationError("Error", errorMessage: "Please input grade")
            return
        }
        
    }
    
    // MARK: - Keyboard Methods
    func keyboardWillShow(notification: NSNotification) {
    }

    func keyboardWillHide(notification: NSNotification) {
    }
    
    func hideKeyboard() {
        self.m_txtViewDescription.resignFirstResponder()
        self.m_txtGrade.resignFirstResponder()
    }

}

extension FeedbackViewController: UITextViewDelegate {
    
    // MARK: - Text View Methods
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if textView.text == "" {
            
            textView.text = descriptionPlaceHolder
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    
}

extension FeedbackViewController: UITextFieldDelegate {
    
    // MARK: - Text Field Methods
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        // Add a 'Done' button on the grade input text field
        let keyboardDoneButtonShow = UIToolbar(frame: CGRectMake(0, 0,  self.view.frame.size.width, self.view.frame.size.height/12))
        keyboardDoneButtonShow.barStyle = UIBarStyle.Default
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(FeedbackViewController.hideKeyboard))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        doneButton.tintColor = UIColor.blueColor()
        let toolbarButton = [flexSpace,doneButton]
        keyboardDoneButtonShow.setItems(toolbarButton, animated: false)
        textField.inputAccessoryView = keyboardDoneButtonShow
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }
}