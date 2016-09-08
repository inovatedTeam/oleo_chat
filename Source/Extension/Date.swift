//
//  Date.swift
//  READY
//
//  Created by Admin on 25/05/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit

extension NSDate {
    func covertToString() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.stringFromDate(self)
    }
}
