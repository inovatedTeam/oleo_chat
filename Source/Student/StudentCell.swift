//
//  TeacherCell.swift
//  READY
//
//  Created by admin on 03/06/16.
//  Copyright © 2016 Andrei. All rights reserved.
//

import UIKit

class StudentCell: UITableViewCell {
    @IBOutlet var imgStudent: UIImageView!
    @IBOutlet var txtName: UILabel!
    @IBOutlet weak var messageBadge: SwiftBadge!
    @IBOutlet weak var txtLastMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        self.imgStudent.layer.cornerRadius = self.imgStudent.bounds.size.width / 2.0
        self.imgStudent.layer.masksToBounds = true
    }

}
