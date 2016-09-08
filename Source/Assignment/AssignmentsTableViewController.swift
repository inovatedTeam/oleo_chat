//
//  AssignmentsTableViewController.swift
//  ready
//
//  Created by Patrick Sheehan on 4/27/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit
import SwiftyJSON

let assignmentCellID = "AssignmentCell"

class AssignmentsTableViewController: UITableViewController {

    var assignments: [Assignment] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = CustomStringLocalization.textForKey("My_Assignments")
        
        getAssignments()
    }

    func getAssignments() {
        LoadingOverlay.shared.showOverlay(TheAppDelegate.window!.rootViewController!.view)
        
        WebServiceAPI.postDataWithURL(Constants.APINames.GetAllAssignments, withoutHeader: false, params: nil, completionBlock: {(request:NSURLRequest?, response:NSHTTPURLResponse?, json:AnyObject)->Void in
            LoadingOverlay.shared.hideOverlayView()
            
            let responseFromServer = JSON(json).dictionary
            
            let bSuccess = responseFromServer!["success"]?.string
            if (bSuccess == "1") {
                self.assignments.removeAll()
                
                let arrayAssignments = responseFromServer!["assignments"]?.array
                for eachAssignment in arrayAssignments! {
                    let assignment = Assignment(fromJSON: eachAssignment.dictionary!)
                    self.assignments.append(assignment)
                }
                
                self.tableView.reloadData()
            } else {
                TheInterfaceManager.showLocalValidationError((responseFromServer!["message"]?.string)!)
            }
            }, errBlock: {(errorString) -> Void in
                TheInterfaceManager.showLocalValidationError(errorString)
                LoadingOverlay.shared.hideOverlayView()
        })
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.assignments.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(assignmentCellID, forIndexPath: indexPath) as! AssignmentCell

        let a = self.assignments[indexPath.row]
        
        cell.m_title?.text = a.title
        cell.m_description?.text = a.descr
        
        cell.m_deadline.text = "\(CustomStringLocalization.textForKey("Deadline")): \(a.deadline!)"
//        cell.m_deadline.text = "Deadline: \(a.deadline!)"
        
        cell.m_completedStatus.text = CustomStringLocalization.textForKey("Incomplete")
        cell.m_completedStatus.textColor = UIColor.blueColor()
        if (a.completed_by_student == "1") {
            cell.m_completedStatus.text = "\(CustomStringLocalization.textForKey("Completed_By")): you"
            cell.m_completedStatus.textColor = UIColor.redColor()
        } else if (a.completed_by_teacher == "1") {
            cell.m_completedStatus.text = "\(CustomStringLocalization.textForKey("Completed_By")): teacher"
            cell.m_completedStatus.textColor = UIColor.redColor()
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let a = self.assignments[indexPath.row]
        
        let viewCon = self.storyboard?.instantiateViewControllerWithIdentifier("CreateAssignmentViewController") as! CreateAssignmentViewController
        viewCon.bViewMode = true
        viewCon.selectedAssignment = a
        
        self.navigationController?.pushViewController(viewCon, animated: true)
    }
}

