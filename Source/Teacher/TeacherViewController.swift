//
//  TeacherViewController.swift
//  READY
//
//  Created by admin on 3/7/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit
import SwiftyJSON

let cellID = "TeacherCell"

class TeacherViewController: BaseViewController {

    // MARK: - IB Outlets
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Member Variables
    var interactor = OtherTeacherIterator()
    var arrayTeachers: Array<User> = []
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = CustomStringLocalization.textForKey("Other_Teachers")

        self.getTeachers()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: CustomStringLocalization.textForKey("Invite"), style: .Plain, target: self, action: nil)

    }
    
    // MARK: - Private Helpers
    private func getTeachers() {
        LoadingOverlay.shared.showOverlay(TheAppDelegate.window!.rootViewController!.view)
        
        self.arrayTeachers.removeAll()
        
        self.tableView.reloadData()
        
        WebServiceAPI.postDataWithURL(Constants.APINames.GetTeachers, withoutHeader: false, params: nil, completionBlock: {(request:NSURLRequest?, response:NSHTTPURLResponse?, json:AnyObject)->Void in
            LoadingOverlay.shared.hideOverlayView()
            
            let responseFromServer = JSON(json).dictionaryObject
            if let teachers = responseFromServer!["teacher"] as? Array<AnyObject> {
                for i in 0..<teachers.count {
                    let eachTeacher: User = User()
                    eachTeacher.loadDictionary(teachers[i] as! NSDictionary)
                    self.arrayTeachers.append(eachTeacher)
                }
            }
            
            self.tableView.reloadData()
            }, errBlock: {(errorString) -> Void in
                LoadingOverlay.shared.hideOverlayView()
        })
 
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
}

extension TeacherViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Table View Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayTeachers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID) as! TeacherCell
        
        let userObject = self.arrayTeachers[indexPath.row]
        cell.txtName.text = userObject.username
        cell.imgTeacher.downloadedFrom(link: userObject.profilePicUrl, contentMode: .ScaleAspectFill)
        cell.txtLastMessage.text = TheGlobalPoolManager.getLastMessage(userObject.username, bStudent: false)
        
        let nMissingMessageCnt = TheGlobalPoolManager.getEachMissingMessagesCnt(userObject.username, bStudent: false)
        if nMissingMessageCnt == 0 {
            cell.messageBadge.hidden = true
        } else {
            cell.messageBadge.hidden = false
            cell.messageBadge.text = "\(nMissingMessageCnt)"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        TheGlobalPoolManager.opponentUser = self.arrayTeachers[indexPath.row]
        self.performSegueWithIdentifier("TeacherMessageSegue", sender: nil)
    }
    
}