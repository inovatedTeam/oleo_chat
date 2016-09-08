//
//  OtherTeacherIterator.swift
//  READY
//
//  Created by OtherTeacherIterator on 06/03/2016.
//  Copyright (c) 2015 Andrei. All rights reserved.
//


import UIKit

class OtherTeacherIterator: NSObject {
    
    /* 
        This will be replaced by messages, games, chats, etc. 
        or with a sleek entity their superclass
    */
    var arrObjects:[AnyObject] = [
        
        [
            "thumbnail":"handsome-suit-guy.jpg",
            "name":"Teacher1",
            "email":"Andrei1@yahoo.com"
        ],
        [
            "thumbnail":"fat-white-lady.jpg",
            "name":"Teacher1",
            "email":"Andrei1@yahoo.com"
        ],
        [
            "thumbnail":"chinese-lady.jpg",
            "name":"Teacher1",
            "email":"Andrei1@yahoo.com"
        ],
        [
            "thumbnail":"pretty-white-girl.jpg",
            "name":"Teacher1",
            "email":"Andrei1@yahoo.com"
        ],
        [
            "thumbnail":"handsome-suit-guy.jpg",
            "name":"Teacher1",
            "email":"Andrei1@yahoo.com"
        ],
        [
            "thumbnail":"fat-white-lady.jpg",
            "name":"Teacher1",
            "email":"Andrei1@yahoo.com"
        ],
        [
            "thumbnail":"handsome-suit-guy.jpg",
            "name":"Teacher1",
            "email":"Andrei1@yahoo.com"
        ],
        [
            "thumbnail":"fat-white-lady.jpg",
            "name":"Teacher1",
            "email":"Andrei1@yahoo.com"
        ],
        [
            "thumbnail":"handsome-suit-guy.jpg",
            "name":"Teacher1",
            "email":"Andrei1@yahoo.com"
        ],
        [
            "thumbnail":"fat-white-lady.jpg",
            "name":"Teacher1",
            "email":"Andrei1@yahoo.com"
        ]
    ]
    
    func addTeacher(param: Dictionary<String, String>) {
        self.arrObjects.append(param)
    }
}
