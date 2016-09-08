//
//  User.swift
//  READY
//
//  Created by Patrick Sheehan on 1/13/16.
//  Copyright (c) 2016 Síocháin. All rights reserved.
//

import UIKit

class User: BaseEntity {
    var id: Int = 0
    var username: String = ""
    var email: String = ""
    var password: String = ""
    var passwordConfirmation: String = ""
    var nativeLanguage: Language = .English
    var type: String = ""
    var profilePic: UIImage?
    var profilePicUrl: String = ""
    var QuickbloxID: UInt = 0
    
    // TODO: synchronize with server
    var targetLanguage: Language = .English
    
    func toH() -> NSDictionary {
        let d = NSMutableDictionary()
        d["userName"] = self.username
        d["email"] = self.email
        d["password"] = self.password
        d["type"] = self.type
        d["lang"] = self.nativeLanguage.code
        d["qb_id"] = "\(self.QuickbloxID)"

        return d
    }

    func loadDictionary(d:NSDictionary) {
        self.id = Int(d["id"] as! String)!
        self.username = d["userName"] as! String
        self.email = d["email"] as! String
        self.type = d["job"] as! String
        self.profilePicUrl = "\(Constants.WebServiceApi.imageBaseUrl)\(d["avatar"] as! String)"
        let langCode = d["lang"] as! String
        self.nativeLanguage = Language(code: langCode)
        self.QuickbloxID = UInt(d["qb_id"] as! String)!
        
        NSLog("got")
    }

}