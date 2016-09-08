//
//  ProfileViewController.swift
//  ready
//
//  Created by Patrick Sheehan on 1/25/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import SwiftyJSON

class ProfileViewController: BaseViewController, UIActionSheetDelegate {

    // MARK: - IB Outlets
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var languageLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var changePicButton: UIButton!
    var selectedImage: UIImage? = nil
    
    // MARK: - Member Variables
    let imagePicker = UIImagePickerController()
    var user: User? = nil
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.delegate = self
        
        // For changing Native Language
        self.languageLabel.userInteractionEnabled = true
        self.languageLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.changeNativeLanguage)))

        // For changing Profile Pic
        self.profileImageView.userInteractionEnabled = true
        self.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.changeProfilePic)))
        
        self.getUser()

        InterfaceManager.addBorderToView(self.profileImageView, toCorner: .AllCorners, cornerRadius: CGSizeMake(5.0, 5.0), withColor: TheInterfaceManager.mainColor, borderSize: 2.0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = CustomStringLocalization.textForKey("Profile")
        
        self.changePicButton.setTitle(CustomStringLocalization.textForKey("Change_Profile_Pic"), forState: .Normal)
        self.languageLabel.text = "\(CustomStringLocalization.textForKey("Native_Language")): \(self.user!.nativeLanguage)"

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: CustomStringLocalization.textForKey("Logoff"), style: .Plain, target: appDelegate(), action: #selector(AppDelegate.logoff))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: CustomStringLocalization.textForKey("Language"), style: .Plain, target: self, action: #selector(ProfileViewController.changeTargetLanguage))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
   
        
        self.showClassRegistrationScreenIfNeeded()

    }
    
    func showClassRegistrationScreenIfNeeded() {
        
        if user?.type == "student" {
            self.checkForEnrollment()
        }
        
    }
    
    func checkForEnrollment() {
        
        WebServiceAPI.postDataWithURL(Constants.APINames.GetEnrolledClassrooms, withoutHeader: false, params: nil, completionBlock: { (request, response, json) in
//            print("Get enrolled classrooms succeeded")
            
            let responseFromServer = JSON(json).dictionary
            
            let bSuccess = responseFromServer!["success"]?.string
            if (bSuccess == "1") {
                
                if let arrayClassrooms = responseFromServer!["classroom"]?.array {
                    if arrayClassrooms.count > 0 {
                        print("Enrolled in at least one class")
                    } else {
                        print("Student is not enrolled in a class, present EnrollClassroomVC screen")
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("EnrollClassroomVC") as! EnrollClassroomViewController
                        
                        self.presentViewController(vc, animated: true, completion: nil)

                    }
                }
            } else {
                TheInterfaceManager.showLocalValidationError((responseFromServer!["message"]?.string)!)
            }

        })
        { (errorString) in
        
            print("Get enrolled classrooms failed")
        }
    }
    
    func updateProfile() {
        LoadingOverlay.shared.showOverlay(self.navigationController?.view)
        
        let paramsDict: Dictionary<String, AnyObject> = [
            "lang":self.user!.nativeLanguage.code,
        ]

        var imageData: NSData? = nil
        if (selectedImage != nil) {
            imageData = UIImageJPEGRepresentation(selectedImage!, 0.6)
        }
        
        WebServiceAPI.postDataWithURLWithResource(Constants.APINames.UpdateProfile, withoutHeader: false, resourceData: imageData, fileName: "avatar.jpg", mimeType: "image/jpg", attachParamName: "file", params: paramsDict, completionBlock: { (request, response, json) -> Void in
            LoadingOverlay.shared.hideOverlayView()

            let responseFromServer = JSON(json).dictionaryObject
            
            let newAvatar = responseFromServer!["avatar"] as! String
            self.user?.profilePicUrl = Constants.WebServiceApi.imageBaseUrl + newAvatar
            
            TheGlobalPoolManager.currentUser?.nativeLanguage = (self.user?.nativeLanguage)!
            TheGlobalPoolManager.currentUser?.profilePicUrl = (self.user?.profilePicUrl)!
            
            }, errBlock: { (errorString) -> Void in
                TheInterfaceManager.showLocalValidationError(errorString)
                LoadingOverlay.shared.hideOverlayView()
                
        })
    }
    
    // MARK: - IB Actions
    @IBAction func changeProfilePic() {
        
        let actionSheet = UIActionSheet.init(title: "Choose your avatar", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Take a Photo", "Choose Photo From Gallery")
        actionSheet.showInView(self.view)
        
        
//        self.imagePicker.allowsEditing = true
//        self.imagePicker.sourceType = .PhotoLibrary
//        self.presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    
    func changeTargetLanguage() {
        
        ActionSheetStringPicker.showPickerWithTitle(CustomStringLocalization.textForKey("Language"), rows: Language.allLanguages(), initialSelection:user!.targetLanguage.rawValue, doneBlock: {
            picker, value, index in
            
            let targetLanguage = Language(rawValue: value)!
            
            print("User changed target language to: \(targetLanguage)")
            
            print("TODO: Update user's target language on the server")
            self.user!.targetLanguage = targetLanguage
            CustomStringLocalization.setTargetLanguage(targetLanguage)
            
            self.viewWillAppear(true)
            
            return
            }, cancelBlock: { ActionStringCancelBlock in return },
               origin: self.navigationItem.rightBarButtonItem)
        
    }
    
    func changeNativeLanguage() {
        ActionSheetStringPicker.showPickerWithTitle(CustomStringLocalization.textForKey("Native_Language"), rows: Language.allLanguages(), initialSelection:user!.nativeLanguage.rawValue , doneBlock: {
            picker, value, index in
            self.languageLabel.text = "\(CustomStringLocalization.textForKey("Native_Language")): \(index as! String)"
            self.user!.nativeLanguage = Language(rawValue: value)!
            
            self.viewWillAppear(true)
            self.updateProfile()
            return
            }, cancelBlock: { ActionStringCancelBlock in return }, origin: self.languageLabel)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 1:
            takeNewPhoto()
        case 2:
            choosePhotoFromLibrary()
        default:
            break
        }
    }
    
    func choosePhotoFromLibrary() {
        self.imagePicker.allowsEditing = true
        self.imagePicker.sourceType = .PhotoLibrary
        self.presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    
    func takeNewPhoto() {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .Camera
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
    }

    // MARK: - Private Helpers
    private func getUser() {
        user = TheGlobalPoolManager.currentUser
        if user != nil {
            usernameLabel.text = user!.username
            languageLabel.text = "\(CustomStringLocalization.textForKey("Native_Language")): \(String(user!.nativeLanguage))"
            
            profileImageView.setNeedsLayout()
            profileImageView.layoutIfNeeded()
            profileImageView.downloadedFrom(link: user!.profilePicUrl, contentMode: .ScaleAspectFill)
        }
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UIImagePicker Delegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.selectedImage = chosenImage
        profileImageView.contentMode = .ScaleAspectFill
        profileImageView.image = self.selectedImage
        self.profileImageView.image = self.selectedImage
        
        dismissViewControllerAnimated(true, completion: nil)
        
        self.updateProfile()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}