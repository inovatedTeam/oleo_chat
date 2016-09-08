//
//  ClassroomViewController.swift
//  READY
//
//  Created by Patrick Sheehan on 9/8/15.
//  Copyright (c) 2015 Siochain. All rights reserved.
//

import UIKit
import SwiftyJSON

let classroomCellIdentifier = "ClassroomCell"

class ClassroomViewController: BaseViewController {
    
    var classes:[Classroom] = []
    var selectedClassroom: Classroom? = nil
    
    // MARK: - IB Outlets
    @IBOutlet var tableView: UITableView!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }

    func getClassrooms() {
        LoadingOverlay.shared.showOverlay(TheAppDelegate.window!.rootViewController!.view)
        
        WebServiceAPI.postDataWithURL(Constants.APINames.GetClassroomsForTeachers, withoutHeader: false, params: nil, completionBlock: {(request:NSURLRequest?, response:NSHTTPURLResponse?, json:AnyObject)->Void in
            LoadingOverlay.shared.hideOverlayView()
            
            let responseFromServer = JSON(json).dictionary

            let bSuccess = responseFromServer!["success"]?.string
            if (bSuccess == "1") {
                self.classes.removeAll()
                
                let arrayClassrooms = responseFromServer!["classroom"]?.array
                for eachClass in arrayClassrooms! {
                    let classroom = Classroom(fromJSON: eachClass.dictionary!)
                    self.classes.append(classroom)
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = CustomStringLocalization.textForKey("My_Classes")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ClassroomViewController.createClassroom))
        
        getClassrooms()
    }
    
    func createClassroom() {
        let viewCon = self.storyboard?.instantiateViewControllerWithIdentifier("CreateClassroomViewController")
        self.navigationController?.pushViewController(viewCon!, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.tableView.reloadData()
        
        print("Setting student1 and student2 to nil")
        TheGlobalPoolManager.student1 = nil
        TheGlobalPoolManager.student2 = nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toStudentList" {
            
            let destVC = segue.destinationViewController as! StudentTableViewController
            destVC.selectedClassroom = self.selectedClassroom
            destVC.title = CustomStringLocalization.textForKey("My_Students")
            destVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: destVC, action: #selector(StudentTableViewController.addAssignmentOrStudent))
        }
    }
    
}

extension ClassroomViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Table View Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.classes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(classroomCellIdentifier, forIndexPath: indexPath)
        
        let thumbnailView = cell.viewWithTag(111) as! UIImageView
        let messageLabel = cell.viewWithTag(222) as! UILabel
        
        let classroom = self.classes[indexPath.row]
        
        thumbnailView.image = classroom.flag
        messageLabel.text = classroom.title
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedClassroom = self.classes[indexPath.row]
        
        self.performSegueWithIdentifier("toStudentList", sender: nil)
    }

}