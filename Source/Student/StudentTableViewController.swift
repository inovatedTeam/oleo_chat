//
//  StudentTableViewController.swift
//  READY
//
//  Created by Admin on 04/03/16.
//  Copyright © 2016 Andrei. All rights reserved.
//

import UIKit
import SwiftyJSON

let studentCellIdentifier = "StudentCell"

class StudentTableViewController: BaseViewController {

    // MARK: - IB Outlets
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Member Variables
    var selectedClassroom: Classroom? = nil

    var arrayStudents:[Student] = []
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let user = TheGlobalPoolManager.currentUser
        if user?.type == "teacher" {
            self.title = CustomStringLocalization.textForKey("My_Students")
            
            self.getStudentsInClassroom()
        } else if user?.type == "student" {
            self.title = CustomStringLocalization.textForKey("My_Classmates")
            
            getStudents()
        }
        
    }
    
    // MARK: - Private Helpers
    private func getStudentsInClassroom() {
        LoadingOverlay.shared.showOverlay(TheAppDelegate.window!.rootViewController!.view)
        
        self.arrayStudents.removeAll()
        
        let params: Dictionary<String, AnyObject> = ["classroom_id": (self.selectedClassroom?.id)!]
        
        WebServiceAPI.postDataWithURL(Constants.APINames.GetStudentsInClassroom, withoutHeader: false, params: params, completionBlock: {(request:NSURLRequest?, response:NSHTTPURLResponse?, json:AnyObject)->Void in
            LoadingOverlay.shared.hideOverlayView()
            
            let responseFromServer = JSON(json).dictionary

            let bSuccess = responseFromServer!["success"]?.string
            if (bSuccess == "1") {
                let students = responseFromServer!["students"]?.array
                for eachStudent in students! {
                    let student = Student(fromJSON: eachStudent.dictionary!)
                    
                    self.arrayStudents.append(student)
                }
                
                self.tableView.reloadData()
            } else {
                TheInterfaceManager.showLocalValidationError((responseFromServer!["message"]?.string)!)
            }
            }, errBlock: {(errorString) -> Void in
                
                LoadingOverlay.shared.hideOverlayView()
                TheInterfaceManager.showLocalValidationError("error-1", errorMessage: errorString)
        })
    }
    
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
                
                self.tableView.reloadData()
            } else {
                TheInterfaceManager.showLocalValidationError((responseFromServer!["message"]?.string)!)
            }
            }, errBlock: {(errorString) -> Void in
                
                LoadingOverlay.shared.hideOverlayView()
                TheInterfaceManager.showLocalValidationError("error-1", errorMessage: errorString)
        })
    }

    func addAssignmentOrStudent() {
        
        let alert = UIAlertController(title: "Please select one of the following", message: nil, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Add Assignment", style: .Default, handler: { (action) in
            print("TODO: Add Assignment page")
            let viewCon = self.storyboard?.instantiateViewControllerWithIdentifier("CreateAssignmentViewController") as! CreateAssignmentViewController
            viewCon.selectedClassroom = self.selectedClassroom
            self.navigationController?.pushViewController(viewCon, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Add Student", style: .Default, handler: { (action) in
            print("TODO: Add Student page")
            let viewCon = self.storyboard?.instantiateViewControllerWithIdentifier("SearchStudentViewController") as! SearchStudentViewController
            viewCon.selectedClassroom = self.selectedClassroom
            self.navigationController?.pushViewController(viewCon, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        
//        if segue.identifier == "goMessageSegue" {
//            let messageViewCon: MessagingViewController = segue.destinationViewController as! MessagingViewController
//            messageViewCon.isConversationWithStudent = true
//        }
//    }
}

extension StudentTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Table View Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.arrayStudents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(studentCellIdentifier, forIndexPath: indexPath) as! StudentCell
        
        let userObject = self.arrayStudents[indexPath.row]
        cell.txtName.text = userObject.userName
        cell.imgStudent.downloadedFrom(link: userObject.profilePicUrl!, contentMode: .ScaleAspectFill)
        cell.txtLastMessage.text = TheGlobalPoolManager.getLastMessage(userObject.userName!, bStudent: true)
        
        let nMissingMessageCnt = TheGlobalPoolManager.getEachMissingMessagesCnt(userObject.userName!, bStudent: true)
        if nMissingMessageCnt == 0 {
            cell.messageBadge.hidden = true
        } else {
            cell.messageBadge.hidden = false
            cell.messageBadge.text = "\(nMissingMessageCnt)"
        }
        
        cell.selectionStyle = .Gray
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let selectedStudent = self.arrayStudents[indexPath.row]
        let selectedUser: User = User()
        selectedUser.id = Int(selectedStudent.id!)!
        selectedUser.username = selectedStudent.userName!
        selectedUser.email = selectedStudent.email!
        selectedUser.profilePicUrl = selectedStudent.avatar!
        selectedUser.QuickbloxID = selectedStudent.qb_id

        
        
        
        let user = TheGlobalPoolManager.currentUser!
        if user.type == "teacher" {
            print("User is a teacher. They want to review conversation")

            if TheGlobalPoolManager.student1 == nil {
                print("Student 1 is nil, assigning: \(selectedUser)")
                TheGlobalPoolManager.student1 = selectedUser
                
                print("Transitioning to another StudentTableViewController")
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("StudentTableViewController") as! StudentTableViewController
                vc.selectedClassroom = self.selectedClassroom
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if TheGlobalPoolManager.student2 == nil {
                print("Student 2 is nil, assigning: \(selectedUser)")
                TheGlobalPoolManager.student2 = selectedUser
                
                print("Transitioning to a ReviewMessagingViewController")
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ReviewMessagingViewController")
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            
        }
        else if user.type == "student" {
            print("User is a student. Open the messaging view for their conversation")
            TheGlobalPoolManager.opponentUser = selectedUser
            
            self.performSegueWithIdentifier("goMessageSegue", sender: nil)
        }
        
        
        
    }
}
