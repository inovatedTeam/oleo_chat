//
//  Message.swift
//  ready
//
//  Created by Patrick Sheehan on 1/15/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import Foundation

class Message: BaseEntity {
    
    var id: Int = 0
    var username: String = ""
    var sender_id: String = ""
    var receiver_id: String = ""
    var time: NSDate = NSDate()
    var link: String = ""
    var media_type: String = ""
    var message: String = ""
    var checked: String = ""
    
    func toH() -> NSDictionary {
        let d = NSMutableDictionary()
        d["userName"] = self.username
        d["sender_id"] = self.sender_id
        d["receiver_id"] = self.receiver_id
        d["link"] = self.link
        d["media_type"] = self.media_type
        d["message"] = self.message
        d["checked"] = self.checked
        d["offset_time"] = self.time
        
        return d
    }
    
    func loadDictionary(d:NSDictionary) {
        self.media_type = d["media_type"] as! String
        self.link = d["link"] as! String
        self.sender_id = d["sender_id"] as! String
        self.receiver_id = d["receiver_id"] as! String
        self.id = Int(d["chat_id"] as! String)!
        self.checked = d["checked"] as! String
        self.username = d["userName"] as! String
        self.message = d["message"] as! String
        self.time = NSDate().dateByAddingTimeInterval(((d["offset_time"] as! NSNumber)).doubleValue)
    }
    
    func loadDictionaryFromPush(d:NSDictionary) {
        self.media_type = d["media_type"] as! String
        self.username = d["userName"] as! String
        self.link = d["media_link"] as! String
        self.sender_id = d["sender_id"] as! String
        self.receiver_id = d["receiver_id"] as! String
        self.id = (d["chat_id"] as! NSNumber).integerValue
        self.message = d["alert"] as! String
        self.time = NSDate()
    }

}
