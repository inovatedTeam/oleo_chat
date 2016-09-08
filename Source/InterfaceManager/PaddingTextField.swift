//
//  PaddingTextField.swift
//  READY
//
//  Created by Admin on 05/03/16.
//  Copyright © 2016 Andrei. All rights reserved.
//

import UIKit

class PaddingTextField: UITextField {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    @IBInspectable var paddingLeft: CGFloat = 0
    @IBInspectable var paddingRight: CGFloat = 0
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectMake(bounds.origin.x + paddingLeft, bounds.origin.y,
            bounds.size.width - paddingLeft - paddingRight, bounds.size.height);
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }
}
