//
//  MessageTableViewCell.swift
//  IPMQuickstart
//
//  Created by Admin on 04/03/16.
//  Copyright © 2016 Andrei. All rights reserved.
//

import UIKit
import SnapKit

class MessageTableViewCell: UITableViewCell {
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        label.textColor = UIColor(red: 0/255.0, green: 128/255.0, blue: 64/255.0, alpha: 1.0)
        return label
    }()
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureSubviews()
    }
    
    // We won’t use this but it’s required for the class to compile
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configureSubviews() {
        self.addSubview(self.nameLabel)
        self.addSubview(self.bodyLabel)
        
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(10)
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
        }
        
        bodyLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(nameLabel.snp_bottom).offset(1)
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
            make.bottom.equalTo(self).offset(-10)
        }
    }
}