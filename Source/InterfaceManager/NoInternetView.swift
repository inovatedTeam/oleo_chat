//
//  NoInternetView.swift
//  Snapcart
//
//  Created by iOSDevStar on 11/8/15.
//  Copyright © 2015 Snapcart. All rights reserved.
//

import UIKit

class NoInternetView: UIView {

    @IBOutlet var content: UIView!
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func initializeWithFrame(frame:CGRect) {
        backgroundColor = UIColor.clearColor()
        NSBundle.mainBundle().loadNibNamed(NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last! as String, owner: self, options: nil)
        
        content.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        addSubview(content)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeWithFrame(CGRectMake(0, 0, frame.size.width, frame.size.height))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeWithFrame(frame)
    }
}
