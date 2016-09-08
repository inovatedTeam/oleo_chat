//
//  Objects.swift
//  READY
//
//  Created by Admin on 26/05/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Classroom {
    let teacher_name: String?
    let teacher_email: String?
    let teacher_avatar: String?
    let teacher_lang: String?
    
    let id: String?
    let title: String?
    let subTitle: String?
    let lang: String?
    let flag: UIImage?

    init(fromJSON json: [String: JSON]) {
        self.teacher_name = json["teacher_name"]?.string
        self.teacher_email = json["email"]?.string
        self.teacher_avatar = json["avatar"]?.string
        self.teacher_lang = json["lang"]?.string

        self.id = json["classroom_id"]?.string
        self.title = json["classroom_title"]?.string
        self.subTitle = json["classroom_subtitle"]?.string
        self.lang = json["classroom_lang"]?.string
        
        self.flag = UIImage(named: Language.getLanguageFlag(self.lang!))
    }

}

struct Assignment {
    let id: String?
    let title: String?
    let descr: String?
    let link: String?
    let media: String?
    let created: String?
    let deadline: String?
    
    let completed_by_teacher: String?
    let completed_by_student: String?
    
    init(fromJSON json: [String: JSON]) {
        self.id = json["id"]?.string
        self.title = json["title"]?.string
        self.descr = json["description"]?.string
        self.link = json["link"]?.string
        self.media = json["media"]?.string
        self.created = json["created"]?.string
        self.deadline = json["deadline"]?.string
        
        self.completed_by_teacher = json["completed_by_teacher"]?.string
        self.completed_by_student = json["completed_by_you"]?.string
    }
}

struct Student {
    let id: String?
    let userName: String?
    let email: String?
    let avatar: String?
    let lang: String?
    let qb_id: UInt
    let profilePicUrl: String?

    init(fromJSON json: [String: JSON]) {
        self.id = json["user_id"]?.string
        self.userName = json["student_name"]?.string
        self.email = json["email"]?.string
        self.avatar = json["avatar"]?.string
        self.profilePicUrl = "\(Constants.WebServiceApi.imageBaseUrl)\(self.avatar!)"

        self.lang = json["lang"]?.string
        self.qb_id = UInt((json["qb_id"]?.string)!)!
    }
}