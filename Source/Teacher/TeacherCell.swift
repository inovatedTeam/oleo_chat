//
//  TeacherCell.swift
//  READY
//
//  Created by admin on 3/7/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit

class TeacherCell: UITableViewCell {

    
    @IBOutlet var imgTeacher: UIImageView!
    @IBOutlet var txtName: UILabel!
    @IBOutlet weak var txtLastMessage: UILabel!
    
    @IBOutlet weak var messageBadge: SwiftBadge!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        self.imgTeacher.layer.cornerRadius = self.imgTeacher.bounds.size.width / 2.0
        self.imgTeacher.layer.masksToBounds = true
    }

}
