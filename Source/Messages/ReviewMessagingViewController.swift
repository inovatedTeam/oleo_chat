//
//  ReviewMessagingViewController.swift
//  ready
//
//  Created by Patrick Sheehan on 7/7/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit
import MediaPlayer
import JSQMessagesViewController
import SwiftyJSON

class ReviewMessagingViewController: MessagingViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Review Conversation"
        self.senderId = TheGlobalPoolManager.student1?.username
        self.senderDisplayName = TheGlobalPoolManager.student1!.username

        self.inputToolbar.removeFromSuperview()
    }
    
    override func getChatHistory() {
        LoadingOverlay.shared.showOverlay(TheAppDelegate.window?.rootViewController!.view)
        
        
        let paramsDict = ["student_id1":"\((TheGlobalPoolManager.student1?.id)!)",
                          "student_id2":"\((TheGlobalPoolManager.student2?.id)!)",
                          "last_id":"\(self.lastMessageID)"]
        
        WebServiceAPI.postDataWithURL(Constants.APINames.GetChatHistoryOfStudents, withoutHeader: false, params: paramsDict, completionBlock: {(request:NSURLRequest?, response:NSHTTPURLResponse?, json:AnyObject)->Void in
            LoadingOverlay.shared.hideOverlayView()
            self.endRefreshing()
            
            let responseFromServer = JSON(json).dictionaryObject
            if let arrayHistory = responseFromServer!["history"] as? Array<AnyObject> {
                
                if arrayHistory.count > 0 {
                    self.performSelector(#selector(MessagingViewController.gotoBottomView), withObject: nil, afterDelay: 0.3)
                }
                
                if arrayHistory.count < messageHistoryBatch {
                    self.bAvailableToLoadPrevMessages = false
                } else {
                    self.bAvailableToLoadPrevMessages = true
                    self.lastMessageID += 1
                }
                
                for i in 0 ..< arrayHistory.count {
                    //load prev messages
                    let message: Message = Message()
                    message.loadDictionary(arrayHistory[i] as! NSDictionary)
                    
                    let bIsMyMessage = Int(message.sender_id)! == (TheGlobalPoolManager.currentUser?.id)! ? true : false
                    
                    if message.media_type == Constants.MessageType.Text{
                        self.showSentTextMessage(bIsMyMessage, messageDate: message.time, text: message.message, bSound: false)
                    } else if message.media_type == Constants.MessageType.Audio {
                        self.showSentAudioMessage(message.link, bIsMyMessage: bIsMyMessage, bSound: false)
                    } else if message.media_type == Constants.MessageType.Video{
                        self.showSentVideoMessage(message.link, bIsMyMessage: bIsMyMessage, bSound: false)
                    }
                }
                
                self.collectionView?.reloadData()
                
                TheGlobalPoolManager.getMissingMessages(false)
            }
            
            }, errBlock: {(errorString) -> Void in
                LoadingOverlay.shared.hideOverlayView()
                self.endRefreshing()
        })
        
    }

    override func showSentTextMessage(bIsMyMessage: Bool, messageDate: NSDate, text: String, bSound: Bool) {
        let userID = bIsMyMessage ? self.senderId : (TheGlobalPoolManager.student2?.username)!
        let userDisplayName = bIsMyMessage ? self.senderDisplayName : (TheGlobalPoolManager.student2?.username)!
        
        let message = JSQMessage(senderId: userID, senderDisplayName: userDisplayName, date: messageDate, text: text)
        
        if bSound {
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            
            MessagingInteractor.sharedInstance.messages.addObject(message)
            
        } else {
            MessagingInteractor.sharedInstance.messages.insertObject(message, atIndex: 0)
        }
        
        self.finishSendingMessageAnimated(true)
    }
    
    override func showSentAudioMessage(audioLink: String, bIsMyMessage: Bool, bSound: Bool) {
        let userID = bIsMyMessage ? self.senderId : (TheGlobalPoolManager.student2?.username)!
        let userDisplayName = bIsMyMessage ? self.senderDisplayName : (TheGlobalPoolManager.student2?.username)!
        
        let audioData = NSData(contentsOfURL: NSURL(string: "\(Constants.WebServiceApi.audioBaseUrl)\(audioLink)")!)
        
        let audioItem: JSQAudioMediaItem = JSQAudioMediaItem(data: audioData)
        let audioMessage: JSQMessage = JSQMessage(senderId: userID, displayName: userDisplayName, media: audioItem)
        
        if bSound {
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            
            MessagingInteractor.sharedInstance.messages.addObject(audioMessage)
        } else {
            MessagingInteractor.sharedInstance.messages.insertObject(audioMessage, atIndex: 0)
        }
        
        self.finishSendingMessageAnimated(true)
    }
    
    override func showSentVideoMessage(videoLink: String, bIsMyMessage: Bool, bSound: Bool) {
        let userID = bIsMyMessage ? self.senderId : (TheGlobalPoolManager.student2?.username)!
        let userDisplayName = bIsMyMessage ? self.senderDisplayName : (TheGlobalPoolManager.student2?.username)!
        
        let videoURL = NSURL(string: "\(Constants.WebServiceApi.videoBaseUrl)\(videoLink)")
        
        let videoItem: JSQVideoMediaItem = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
        let videoMessage: JSQMessage = JSQMessage(senderId: userID, displayName: userDisplayName, media: videoItem)
        
        if bSound {
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            
            MessagingInteractor.sharedInstance.messages.addObject(videoMessage)
        } else {
            MessagingInteractor.sharedInstance.messages.insertObject(videoMessage, atIndex: 0)
        }
        
        self.finishSendingMessageAnimated(true)
    }

    override func loadAvatarImages() {
        self.collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        UIImage.downloadedFrom(link: (TheGlobalPoolManager.student2?.profilePicUrl)!, completionHandler: {(image) -> Void in
            self.opponentUserAvatar = image!
        })
    }


}
