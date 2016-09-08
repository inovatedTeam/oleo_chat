//
//  AssignmentCell.swift
//  READY
//
//  Created by Admin on 27/05/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit

class AssignmentCell: UITableViewCell {

    @IBOutlet weak var m_title: UILabel!
    @IBOutlet weak var m_deadline: UILabel!
    @IBOutlet weak var m_description: UILabel!
    @IBOutlet weak var m_completedStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
