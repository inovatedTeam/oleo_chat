//
//  StudentTableViewController.swift
//  READY
//
//  Created by Admin on 04/03/16.
//  Copyright © 2016 Andrei. All rights reserved.
//

import UIKit
import SwiftyJSON

let searchStudentCellIdentifier = "StudentCell"

class SearchStudentViewController: BaseViewController, UIAlertViewDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet var m_tableView: UITableView!
    
    // MARK: - Member Variables
    var selectedClassroom: Classroom? = nil
    var arrayStudents:[Student] = []
    var selectedArrayStudents: [String] = []
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        self.m_tableView.tableFooterView = UIView()
        self.m_tableView.allowsMultipleSelection = true
        self.m_tableView.delegate = self
        self.m_tableView.dataSource = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Invite", style: .Plain, target: self, action: #selector(SearchStudentViewController.inviteStudents))
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = CustomStringLocalization.textForKey("Students")
        
        getStudents()
    }
    
    func inviteStudents() {
        if (self.selectedArrayStudents.count == 0) {
            TheInterfaceManager.showLocalValidationError("Please select one more students at least!")
            return
        }
        
        LoadingOverlay.shared.showOverlay(TheAppDelegate.window!.rootViewController!.view)
        
        let paramsDict: Dictionary<String, AnyObject> = [
            "classroom_id": (self.selectedClassroom?.id)!,
            "students": self.selectedArrayStudents.joinWithSeparator(",")
        ]
        
        WebServiceAPI.postDataWithURL(Constants.APINames.JoinStudentsClassroom, withoutHeader: false, params: paramsDict, completionBlock: {(request:NSURLRequest?, response:NSHTTPURLResponse?, json:AnyObject)->Void in
            LoadingOverlay.shared.hideOverlayView()
            
            let responseFromServer = JSON(json).dictionary
            
            let bSuccess = responseFromServer!["success"]?.string
            if (bSuccess == "1") {
                let alertView = UIAlertView(title: "Ready", message: "Invited students successfully!", delegate: self, cancelButtonTitle: "OK")
                alertView.show()
            } else {
                TheInterfaceManager.showLocalValidationError((responseFromServer!["message"]?.string)!)
            }
            }, errBlock: {(errorString) -> Void in
                
                LoadingOverlay.shared.hideOverlayView()
                TheInterfaceManager.showLocalValidationError("error-1", errorMessage: errorString)
        })
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    // MARK: - Private Helpers
    private func getStudents() {
        LoadingOverlay.shared.showOverlay(TheAppDelegate.window!.rootViewController!.view)
        
        self.arrayStudents.removeAll()
        
        WebServiceAPI.postDataWithURL(Constants.APINames.GetStudents, withoutHeader: false, params: nil, completionBlock: {(request:NSURLRequest?, response:NSHTTPURLResponse?, json:AnyObject)->Void in
            LoadingOverlay.shared.hideOverlayView()
            
            let responseFromServer = JSON(json).dictionary
            
            let bSuccess = responseFromServer!["success"]?.string
            if (bSuccess == "1") {
                let students = responseFromServer!["student"]?.array
                for eachStudent in students! {
                    let student = Student(fromJSON: eachStudent.dictionary!)
                    
                    self.arrayStudents.append(student)
                }
                
                self.m_tableView.reloadData()
            } else {
                TheInterfaceManager.showLocalValidationError((responseFromServer!["message"]?.string)!)
            }
            }, errBlock: {(errorString) -> Void in
                
                LoadingOverlay.shared.hideOverlayView()
                TheInterfaceManager.showLocalValidationError("error-1", errorMessage: errorString)
        })
    }
}

extension SearchStudentViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Table View Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.arrayStudents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(studentCellIdentifier, forIndexPath: indexPath) as! StudentCell
        
        let userObject = self.arrayStudents[indexPath.row]
        cell.txtName.text = userObject.userName
        cell.imgStudent.downloadedFrom(link: userObject.avatar!, contentMode: .ScaleAspectFill)
        cell.txtLastMessage.text = TheGlobalPoolManager.getLastMessage(userObject.userName!, bStudent: true)
        
        let nMissingMessageCnt = TheGlobalPoolManager.getEachMissingMessagesCnt(userObject.userName!, bStudent: true)
        if nMissingMessageCnt == 0 {
            cell.messageBadge.hidden = true
        } else {
            cell.messageBadge.hidden = false
            cell.messageBadge.text = "\(nMissingMessageCnt)"
        }
        
        if (self.selectedArrayStudents.contains(userObject.id!)) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! StudentCell
        
        let selectedStudent = self.arrayStudents[indexPath.row]
        
        if (self.selectedArrayStudents.contains(selectedStudent.id!)) {
            selectedCell.accessoryType = .None

            let nIndex = self.selectedArrayStudents.indexOf(selectedStudent.id!)
            self.selectedArrayStudents.removeAtIndex(nIndex!)
        } else {
            selectedCell.accessoryType = .Checkmark
            
            self.selectedArrayStudents.append(selectedStudent.id!)
        }
    }
}
