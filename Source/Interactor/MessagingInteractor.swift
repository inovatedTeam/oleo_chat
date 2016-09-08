//
//  MessagingInteractor.swift
//  ready
//
//  Created by Patrick Sheehan on 1/24/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class MessagingInteractor {
    
    static let sharedInstance = MessagingInteractor()

    var messages: NSMutableArray = []
    
    private init() {
        
    }
}

extension JSQMessage {
    func getAvatar(image: UIImage) -> JSQMessagesAvatarImage {
        return JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: 30)
    }
}
