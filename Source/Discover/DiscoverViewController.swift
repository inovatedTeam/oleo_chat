//
//  DiscoverViewController.swift
//  READY
//
//  Created by admin on 3/6/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit

let discoverCell = "discoverCell"

class DiscoverViewController: BaseViewController {

    // MARK: - Member Variables
    let topics: [String] = [
    
        "あなたの家族は昨晩の夕食に何を食べたのですか",
        "Parlez de la météo aujourd'hui",
        "今日の天気について話します",
        "Cad a rinne do theaghlach don dinnéar aréir?",
        "Was hat Ihre Familie gestern Abend zum Abendessen?"
    
    ]
    
    // MARK: - IB Outlets
    @IBOutlet var tableView: UITableView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        self.tableView.tableFooterView = UIView()
        self.title = CustomStringLocalization.textForKey("Discover")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "discoverTopicSegue" {
//            let topicVC = segue.destinationViewController as! ClassroomViewController
//        }
    }
}

extension DiscoverViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table View Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(discoverCell) as! DiscoverTableViewCell
        cell.txtDiscover.text = topics[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        self.performSegueWithIdentifier("discoverTopicSegue", sender: nil)
    }
}