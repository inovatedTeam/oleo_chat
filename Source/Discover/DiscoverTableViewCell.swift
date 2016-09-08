//
//  DiscoverTableViewCell.swift
//  READY
//
//  Created by admin on 3/7/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit

class DiscoverTableViewCell: UITableViewCell {

    
//    @IBOutlet var discoverImage: UIImageView!
    @IBOutlet var txtDiscover: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
//        self.discoverImage.layer.cornerRadius = self.discoverImage.bounds.size.width / 2.0
//        self.discoverImage.layer.masksToBounds = true
    }

}
