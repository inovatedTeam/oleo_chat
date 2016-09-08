//
//  MessagingViewController.swift
//  ready
//
//  Created by Admin on 06/03/16.
//  Copyright © 2016 Andrei. All rights reserved.
//

import UIKit
import MediaPlayer
import JSQMessagesViewController
import SwiftyJSON

let messageHistoryBatch = 10

class MessagingViewController: JSQMessagesViewController, VideoMessageViewControllerDelegate, AudioRecorderViewControllerDelegate {

    // MARK: - Member Variables
    var refreshControl: UIRefreshControl? = nil
    var lastMessageID: Int = 0
    var bAvailableToLoadPrevMessages: Bool = false
    var curSentTextMessage: String = ""
    var opponentUserAvatar: UIImage = UIImage(named: "profile-icon.png")!
    var bShowMediaViews: Bool = false
    let tabViewController = appDelegate.window!.rootViewController as! UITabBarController

    // MARK: - IB Outlets
    @IBOutlet weak var feedbackButton: UIButton!
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MessagingInteractor.sharedInstance.messages.removeAllObjects()
        
        self.addRefreshControl()
        self.addCustomAccessories()
        
//        self.feedbackButton.hidden = true
        self.feedbackButton.setTitle(CustomStringLocalization.textForKey("Feedback"), forState: .Normal)
//        if self.isConversationWithStudent {
            self.feedbackButton.hidden = false
//        }
        
        self.inputToolbar?.contentView?.textView?.pasteDelegate = self
        self.showLoadEarlierMessagesHeader = false

        self.senderId = TheGlobalPoolManager.currentUser!.username
        self.senderDisplayName = TheGlobalPoolManager.currentUser!.username
        
        self.loadAvatarImages()

        self.getChatHistory()
    }

    override func viewWillAppear(animated: Bool) {
        self.bShowMediaViews = false
        TheGlobalPoolManager.curMessageViewCon = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        if self.bShowMediaViews {
            return
        }
        
        TheGlobalPoolManager.curMessageViewCon = nil
    }
    
    func addCustomAccessories() {
        let fInputToolbarHeight = self.inputToolbar?.bounds.size.height
        let fCustomMediaButtonHeight: CGFloat = 24.0
        let fCustomMediaButtonCanvasHeight: CGFloat = 32.0
        
        let fButtonTop = (fInputToolbarHeight! - fCustomMediaButtonHeight) / 2.0
        let fButtonleft = (fCustomMediaButtonCanvasHeight - fCustomMediaButtonHeight) / 2.0
        
        var mediaButtonCanvasWidth = fCustomMediaButtonCanvasHeight * 2.0
        if (TheGlobalPoolManager.currentUser?.type == "student") {
            mediaButtonCanvasWidth = fCustomMediaButtonCanvasHeight * 3.0
        }
        
        let contentView: UIView = UIView(frame: CGRectMake(0.0, 0.0, mediaButtonCanvasWidth, fInputToolbarHeight!))

        let audioButton = UIButton(type: .System)
        audioButton.frame = CGRectMake(fButtonleft, fButtonTop, fCustomMediaButtonHeight, fCustomMediaButtonHeight)
        audioButton.setImage(UIImage(named: "audio.png"), forState: .Normal)
//        audioButton.tintColor = UIColor.lightGrayColor()
        audioButton.addTarget(self, action: #selector(MessagingViewController.tapAudioPressed), forControlEvents: .TouchUpInside)
        contentView.addSubview(audioButton)
        
        let videoButton = UIButton(type: .System)
        videoButton.frame = CGRectMake(fCustomMediaButtonCanvasHeight + fButtonleft, fButtonTop, fCustomMediaButtonHeight, fCustomMediaButtonHeight)
        videoButton.setImage(UIImage(named: "video.png"), forState: .Normal)
//        videoButton.tintColor = UIColor.lightGrayColor()
        videoButton.addTarget(self, action: #selector(MessagingViewController.tapVideoPressed), forControlEvents: .TouchUpInside)
        contentView.addSubview(videoButton)
        
        if (TheGlobalPoolManager.currentUser?.type == "student") {
            let videoCallButton = UIButton(type: .System)
            videoCallButton.frame = CGRectMake(fCustomMediaButtonCanvasHeight * 2  + 2 * fButtonleft, fButtonTop, fCustomMediaButtonHeight, fCustomMediaButtonHeight)
            videoCallButton.setImage(UIImage(named: "call.png"), forState: .Normal)
            //        videoButton.tintColor = UIColor.lightGrayColor()
            videoCallButton.addTarget(self, action: #selector(MessagingViewController.doVideoCall), forControlEvents: .TouchUpInside)
            contentView.addSubview(videoCallButton)
        }
        
        self.inputToolbar?.contentView?.leftBarButtonItem = nil
        self.inputToolbar?.contentView!.leftBarButtonItemWidth = mediaButtonCanvasWidth
        self.inputToolbar?.contentView?.addSubview(contentView)
    }
    
    func gotoBottomView() {
        let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
        let lastItemIndex = NSIndexPath(forItem: item, inSection: 0)
        self.collectionView?.scrollToItemAtIndexPath(lastItemIndex, atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
    }
    
    func doVideoCall() {
        if let _ = TheVideoCallManager.callWithConferenceType(.Video, opponentID: NSNumber(unsignedLong: (TheGlobalPoolManager.opponentUser?.QuickbloxID)!)) {
            TheGlobalPoolManager.bCallerUser = true
            
            let viewCon: VideoCallViewController = self.storyboard?.instantiateViewControllerWithIdentifier("videocallview") as! VideoCallViewController
            viewCon.strOpponentUserName = (TheGlobalPoolManager.opponentUser?.username)!
            viewCon.strOpponentUserProfileUrl = (TheGlobalPoolManager.opponentUser?.profilePicUrl)!
            
            viewCon.bOutComingCall = true
            
            self.presentViewController(viewCon, animated: true, completion: nil)
        }
    }
    
    func getChatHistory() {
        LoadingOverlay.shared.showOverlay(TheAppDelegate.window?.rootViewController!.view)
        
        let paramsDict = ["receiver_id":"\((TheGlobalPoolManager.opponentUser?.id)!)", "last_id":"\(self.lastMessageID)"]
        
        WebServiceAPI.postDataWithURL(Constants.APINames.GetChatHistory, withoutHeader: false, params: paramsDict, completionBlock: {(request:NSURLRequest?, response:NSHTTPURLResponse?, json:AnyObject)->Void in
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
    
    func tapAudioPressed() {
        self.bShowMediaViews = true

        let viewCon: AudioRecorderViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AudioRecorderViewController") as! AudioRecorderViewController
        viewCon.delegate = self
        self.presentViewController(viewCon, animated: true, completion: nil)
    }
    
    func dismissAudioRecordViewCon(viewCon: AudioRecorderViewController, closeMode: Bool, audioPath: NSURL?) {
        viewCon.dismissViewControllerAnimated(true, completion: nil)

        if closeMode {
            //upload audio to server
            self.sendMessageToServer(Constants.MessageType.Audio, media: NSData(contentsOfURL: audioPath!), message: "", fileName: "audio.m4a", mimeType: "audio/mp4")
        }
    }
    
    func showSentAudioMessage(audioLink: String, bIsMyMessage: Bool, bSound: Bool) {
        let userID = bIsMyMessage ? self.senderId : (TheGlobalPoolManager.opponentUser?.username)!
        let userDisplayName = bIsMyMessage ? self.senderDisplayName : (TheGlobalPoolManager.opponentUser?.username)!
        
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
    
    func tapVideoPressed() {
        self.bShowMediaViews = true

        let viewCon: VideoMessageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("VideoMessageViewController") as! VideoMessageViewController
        viewCon.delegate = self
        self.presentViewController(viewCon, animated: true, completion: nil)
    }
    
    func checkVideo(viewCon: VideoMessageViewController, recordVideoPath: NSURL) {
        viewCon .dismissViewControllerAnimated(true, completion: nil);
        
        //upload video to server
        self.sendMessageToServer(Constants.MessageType.Video, media: NSData(contentsOfURL: recordVideoPath), message: "", fileName: "video.mov", mimeType: "video/quicktime")
        //delete video
        /*
        do {
            try NSFileManager.defaultManager().removeItemAtURL(recordVideoPath)
        } catch _ {
        }
        */
    }
    
    func showSentVideoMessage(videoLink: String, bIsMyMessage: Bool, bSound: Bool) {
        let userID = bIsMyMessage ? self.senderId : (TheGlobalPoolManager.opponentUser?.username)!
        let userDisplayName = bIsMyMessage ? self.senderDisplayName : (TheGlobalPoolManager.opponentUser?.username)!

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

    func showReceiveMessages(receiveMessage: Message) {
        if receiveMessage.media_type == Constants.MessageType.Text{
            self.showSentTextMessage(false, messageDate: NSDate(), text:receiveMessage.message, bSound: true)
        } else if receiveMessage.media_type == Constants.MessageType.Audio {
            self.showSentAudioMessage(receiveMessage.link, bIsMyMessage: false, bSound: true)
        } else if receiveMessage.media_type == Constants.MessageType.Video{
            self.showSentVideoMessage(receiveMessage.link, bIsMyMessage: false, bSound: true)
        }
        
        self.checkMessage("\(receiveMessage.id)")
    }
    
    func checkMessage(chatID: String) {
        let paramsDict = ["chat_id":chatID];
        
        WebServiceAPI.postDataWithURL(Constants.APINames.CheckMessage, withoutHeader: false, params: paramsDict, completionBlock: {(request:NSURLRequest?, response:NSHTTPURLResponse?, json:AnyObject)->
            Void in
                NSLog("check message")
            }, errBlock: {(errorString) -> Void in
                NSLog("failed to check message'")
        })
    }
    
    func sendMessageToServer(messageType: String, media: NSData?, message: String, fileName: String, mimeType: String) {
        LoadingOverlay.shared.showOverlay(TheAppDelegate.window?.rootViewController!.view)
        
        let params = ["receiver_id": "\((TheGlobalPoolManager.opponentUser?.id)!)", "media_type":messageType, "message":message]
        WebServiceAPI.sendMessageWithMedia(media, fileName: fileName, mimeType: mimeType, attachParamName: "media", url: Constants.APINames.SendMessage, params: params, completionBlock: {(media_link, media_type) -> Void in
                LoadingOverlay.shared.hideOverlayView()
                if media_type == Constants.MessageType.Text{
                    self.showSentTextMessage(true, messageDate: NSDate(), text:self.curSentTextMessage, bSound: true)
                } else if media_type == Constants.MessageType.Audio {
                    self.showSentAudioMessage(media_link!, bIsMyMessage: true, bSound: true)
                } else if media_type == Constants.MessageType.Video{
                    self.showSentVideoMessage(media_link!, bIsMyMessage: true, bSound: true)
                }
            }, errBlock: {(errorString) -> Void in
                LoadingOverlay.shared.hideOverlayView()
        })
    }
    
    func playVideoMessage(fileURL: NSURL) {
        let videoPlayer: MPMoviePlayerViewController = MPMoviePlayerViewController()
        videoPlayer.moviePlayer.movieSourceType = .Streaming
        videoPlayer.moviePlayer.contentURL = fileURL
        self.presentMoviePlayerViewControllerAnimated(videoPlayer)
    }
    
    func addRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Loading earlier messages...")
        self.refreshControl!.addTarget(self, action: #selector(MessagingViewController.loadEarlierMessages), forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView!.addSubview(self.refreshControl!) // not required when using UITableViewController
    }
    
    func loadEarlierMessages() {
        // Code to refresh table view
        if !self.bAvailableToLoadPrevMessages {
            self.endRefreshing()
            return
        }

        self.getChatHistory()
    }

    func endRefreshing() {
        self.refreshControl!.endRefreshing()
    }
    
    func loadAvatarImages() {
        self.collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero

//        let pic = TheGlobalPoolManager.opponentUser?.profilePic
        let picURL = TheGlobalPoolManager.opponentUser?.profilePicUrl
        
        let realURL = "\(Constants.WebServiceApi.imageBaseUrl)\(picURL!)"
        //        UIImage.downloadedFrom(link: (TheGlobalPoolManager.opponentUser?.profilePicUrl)!, completionHandler: {(image) -> Void in
        UIImage.downloadedFrom(link: realURL, completionHandler: {(image) -> Void in
            self.opponentUserAvatar = image!
            self.collectionView.reloadData()
        })
    }
    
    // MARK: - JSQMessagesViewController method overrides
    func showSentTextMessage(bIsMyMessage: Bool, messageDate: NSDate, text: String, bSound: Bool) {
        let userID = bIsMyMessage ? self.senderId : (TheGlobalPoolManager.opponentUser?.username)!
        let userDisplayName = bIsMyMessage ? self.senderDisplayName : (TheGlobalPoolManager.opponentUser?.username)!

        let message = JSQMessage(senderId: userID, senderDisplayName: userDisplayName, date: messageDate, text: text)
        
        if bSound {
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            
            MessagingInteractor.sharedInstance.messages.addObject(message)
            
        } else {
            MessagingInteractor.sharedInstance.messages.insertObject(message, atIndex: 0)
        }
        
        self.finishSendingMessageAnimated(true)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        /**
        *  Sending a message. Your implementation of this method should do *at least* the following:
        *
        *  1. Play sound (optional)
        *  2. Add new id<JSQMessageData> object to your data source
        *  3. Call `finishSendingMessage`
        */
        
        self.curSentTextMessage = text
        self.sendMessageToServer(Constants.MessageType.Text, media: nil, message: text, fileName: "", mimeType: "")

    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        // This is where we prompt for a multimedia message (audio, video, or location)
        
        self.inputToolbar?.contentView?.textView?.resignFirstResponder()
        
        let alert = UIAlertController(title: "Attach Media", message: nil, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Audio Recording", style: .Default, handler: { (action) -> Void in
            
            let audioRecorder = self.storyboard?.instantiateViewControllerWithIdentifier("AudioRecorderViewController") as! AudioRecorderViewController
            self.navigationController?.pushViewController(audioRecorder, animated: true)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Video Recording", style: .Default, handler: { (action) -> Void in
            
            let audioRecorder = self.storyboard?.instantiateViewControllerWithIdentifier("VideoMessageViewController") as! VideoMessageViewController
            self.navigationController?.pushViewController(audioRecorder, animated: true)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Collection View Methods
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MessagingInteractor.sharedInstance.messages.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let msg = MessagingInteractor.sharedInstance.messages.objectAtIndex(indexPath.item)
        if msg.senderId() == self.senderId {
            cell.textView?.textColor = UIColor.blackColor()
        }
        else {
            cell.textView?.textColor = UIColor.whiteColor()
        }
        
        return cell

    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        return MessagingInteractor.sharedInstance.messages.objectAtIndex(indexPath.item) as! JSQMessageData
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        MessagingInteractor.sharedInstance.messages.removeObjectAtIndex(indexPath.item)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let msg = MessagingInteractor.sharedInstance.messages.objectAtIndex(indexPath.item)
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        if msg.senderId() == self.senderId {
            return bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
        }
        else {
            return bubbleFactory.incomingMessagesBubbleImageWithColor(Constants.Colors.Lavender)
        }

    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
            /**
            *  Return your previously created avatar image data objects.
            *
            *  Note: these the avatars will be sized according to these values:
            *
            *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
            *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
            *
            *  Override the defaults in `viewDidLoad`
            */
        
        let msg = MessagingInteractor.sharedInstance.messages.objectAtIndex(indexPath.item) as! JSQMessage
        
        if msg.senderId == self.senderId {
            return nil
        } else {
            return msg.getAvatar(self.opponentUserAvatar)
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        
        print("TODO: Need to do some translation heaya!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        let message = MessagingInteractor.sharedInstance.messages[indexPath.row] as! JSQMessage
        if message.isMediaMessage {
            if let video = message.media as? JSQVideoMediaItem {
                //video message
                NSLog("video message tappped")
                self.playVideoMessage(video.fileURL)
            }
            
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
        print("TODO: need to load earlier messages")
    }
    
}

extension MessagingViewController: JSQMessagesComposerTextViewPasteDelegate {
    func composerTextView(textView: JSQMessagesComposerTextView!, shouldPasteWithSender sender: AnyObject!) -> Bool {

        if let image = UIPasteboard.generalPasteboard().image {
            let item = JSQPhotoMediaItem(image: image)
            let message = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: NSDate(), media: item)
            MessagingInteractor.sharedInstance.messages.addObject(message)
            self.finishSendingMessage()
            return false
        }
        
        return true
    }
}

