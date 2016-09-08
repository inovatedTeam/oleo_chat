//
//  VideoCallManager.swift
//  VideoChat
//
//  Created by Admin on 25/02/16.
//  Copyright © 2016 RonnieAlex. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import AVFoundation
import AssetsLibrary

protocol VideoCallManagerDelegate {
    func callErrors(description: String)
    func acceptedByUser ()
}

let TheVideoCallManager = VideoCallManager.sharedInstance

let kChatPresenceTimeInterval:NSTimeInterval = 45
let kQBAnswerTimeInterval:NSTimeInterval = 60
let kQBRTCDisconnectTimeInterval:NSTimeInterval = 30
let kQBDialingTimeInterval:NSTimeInterval = 5

class VideoCallManager: NSObject, QBChatDelegate, QBRTCClientDelegate, AVCaptureFileOutputRecordingDelegate, AVAudioRecorderDelegate {
    static let sharedInstance = VideoCallManager()
    
    var recorder: AVAudioRecorder!
    var bRecording: Bool = false
    
    var delegate: VideoCallManagerDelegate? = nil
    
    var presenceTimer: QBRTCTimer? = nil
    var currentSession: QBRTCSession? = nil
    
    var opponentUserID: NSNumber? = nil
    var bIncomingCall: Bool? = false
    
    var timeDuration: NSTimeInterval?
    var callTimer: NSTimer? = nil
    var beepTimer: NSTimer? = nil
    
    var bAudioInCall = true
    
    var currentVideoCallViewCon: VideoCallViewController? = nil
    
    override init() {
        super.init()
    }
    
    func initProcess () {
        QBRTCConfig.setAnswerTimeInterval(kQBAnswerTimeInterval)
        QBRTCConfig.setDisconnectTimeInterval(kQBRTCDisconnectTimeInterval)
        QBRTCConfig.setDialingTimeInterval(kQBDialingTimeInterval)
        
        QBRTCClient.initializeRTC()
    }
    
    func applyConfiguration () {
        var iceServers: Array<AnyObject> = []
        iceServers.appendContentsOf(self.quickbloxICE())
        
        QBRTCConfig.setICEServers(iceServers)
        QBRTCConfig.setMediaStreamConfiguration(QBRTCMediaStreamConfiguration.defaultConfiguration())
        QBRTCConfig.setStatsReportTimeInterval(1.0)
        
        QBRTCClient.instance().addDelegate(self)

    }
    
    func quickbloxICE() -> Array<AnyObject> {
        let password = "baccb97ba2d92d71e26eb9886da5f1e0"
        let username = "quickblox"
        
        let stunServer: QBRTCICEServer = QBRTCICEServer(URL: "stun:turn.quickblox.com", username: "", password: "")
        let turnUDPServer: QBRTCICEServer = QBRTCICEServer(URL: "turn:turn.quickblox.com:3478?transport=udp", username: username, password: password)
        let turnTCPServer: QBRTCICEServer = QBRTCICEServer(URL: "turn:turn.quickblox.com:3478?transport=tcp", username: username, password: password)
        
        return [stunServer, turnUDPServer, turnTCPServer]
    }

    func recordSoundSetting() {
        // Set the audio file
        let pathComponents: [String] = [NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!, "audio.m4a"]
        
        let outputFileURL = NSURL.fileURLWithPathComponents(pathComponents)
        
        // Setup audio session
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions:.DefaultToSpeaker)
            //try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        }
        catch {
            print("Failed to setup AVAudioSession")
        }
        
        // Define the recorder setting
        var recordSetting = [String: AnyObject]()
        recordSetting[AVFormatIDKey] = NSNumber(unsignedInt: kAudioFormatMPEG4AAC)
        recordSetting[AVSampleRateKey] = NSNumber(float:44100.0)
        recordSetting[AVNumberOfChannelsKey] = NSNumber(int: 2)
        
        // Initiate and prepare the recorder
        do {
            try recorder = AVAudioRecorder(URL: outputFileURL!, settings: recordSetting)
            
            recorder.delegate = self
            recorder.meteringEnabled = true
            recorder.prepareToRecord()
        }
        catch {
            print("Failed to setup AVAudioRecorder")
        }
    }

    func chatLoginWithUser(user: QBUUser, completionError:((bSuccess:Bool, error: NSError?) -> Void)) -> Void {
        QBChat.instance().addDelegate(self)
        
        if QBChat.instance().isConnected() {
            completionError(bSuccess:false, error: nil)
            return
        }
        
        QBChat.instance().connectWithUser(user, completion: { (error) -> Void in
            if error == nil {
                self.applyConfiguration()
                
                completionError(bSuccess:true, error: nil)
            } else {
                completionError(bSuccess:false, error: error)
            }
        })
    }

    func chatLogout () {
        if self.presenceTimer != nil {
            self.presenceTimer?.invalidate()
            self.presenceTimer = nil
        }
        
        if QBChat.instance().isConnected() {
            QBChat.instance().disconnectWithCompletionBlock({ (error) -> Void in
                QBRTCClient.instance().addDelegate(nil)
            })
        }
    }
    
    //call process
    func callWithConferenceType(conferenceType: QBRTCConferenceType, opponentID: NSNumber) -> Bool? {
        let session: QBRTCSession? = QBRTCClient.instance().createNewSessionWithOpponents([opponentID], withConferenceType: .Video)
        
        if let session = session {
            self.opponentUserID = opponentID
            self.currentSession = session
            
            bAudioInCall = true
            
            return true
        }
        
        return false
    }
    
    func configureGUI() {
//        self.currentSession?.localMediaStream.videoTrack.enabled = true
//        self.currentSession?.localMediaStream.audioTrack.enabled = true
    }
    
    func muteSound() {
        bAudioInCall = !bAudioInCall
        self.currentSession?.localMediaStream.audioTrack.enabled = bAudioInCall
    }
    
    func stopCallingRingToneSound() {
        if beepTimer != nil {
            beepTimer?.invalidate()
            beepTimer = nil
        }
        
        QMSoundManager.instance().stopAllSounds()
    }
    
    func declineCall(session: QBRTCSession!) {
        if beepTimer != nil {
            beepTimer?.invalidate()
            beepTimer = nil
        }
        
        self.bIncomingCall = false

        QMSoundManager.instance().stopAllSounds()
        QMSoundManager.playEndOfCallSound();
        
        if session != nil {
            session.rejectCall(["hangup":"hang up"])
        }
    }
    
    func rejectCall(session: QBRTCSession!) {
        if beepTimer != nil {
            beepTimer?.invalidate()
            beepTimer = nil
        }

        self.bIncomingCall = false

        QMSoundManager.instance().stopAllSounds()
        QMSoundManager.playEndOfCallSound();
        
        if session != nil {
            session.rejectCall(["reject":"busy"])
        }
    }
    
    func endCall() {
        if beepTimer != nil {
            beepTimer?.invalidate()
            beepTimer = nil
        }

        self.bIncomingCall = false
        
        QMSoundManager.instance().stopAllSounds()
        QMSoundManager.playEndOfCallSound();
        
        if self.currentSession != nil {
            self.currentSession?.hangUp(["end":"end of call"])
        }
    }
    
    func startCall() {
        if beepTimer != nil {
            beepTimer?.invalidate()
            beepTimer = nil
        }

        self.bIncomingCall = false

        self.beepTimer = NSTimer.scheduledTimerWithTimeInterval(QBRTCConfig.dialingTimeInterval(), target: self, selector: #selector(VideoCallManager.playCallingSound), userInfo: nil, repeats: true)
        
        self.playCallingSound()
        
        if self.currentSession != nil {
            self.currentSession?.startCall(["startCall":String(format: "%d", (TheGlobalPoolManager.currentUser?.QuickbloxID)!)])
        }
    }
    
    func acceptCall() {
        if beepTimer != nil {
            beepTimer?.invalidate()
            beepTimer = nil
        }

        QMSoundManager.instance().stopAllSounds()
        if self.currentSession != nil {
            self.currentSession?.acceptCall(["startCall":String(format: "%d", (TheGlobalPoolManager.currentUser?.QuickbloxID)!)])
        }
    }
    
    func incomingCall() {
        if beepTimer != nil {
            beepTimer?.invalidate()
            beepTimer = nil
        }
        
        self.beepTimer = NSTimer.scheduledTimerWithTimeInterval(QBRTCConfig.dialingTimeInterval(), target: self, selector: #selector(VideoCallManager.playRingToneSound), userInfo: nil, repeats: true)
    }
    
    func playCallingSound() {
        QMSoundManager.playCallingSound()
    }
    
    func playRingToneSound() {
        QMSoundManager.playRingtoneSound()
    }
    
    //QBChatDelegate
    func chatDidNotConnectWithError(error: NSError?) {
    }
    
    func chatDidAccidentallyDisconnect() {
    }
    
    func chatDidFailWithStreamError(error: NSError?) {
    }
    
    func chatDidConnect() {
        QBChat.instance().sendPresence()
        
        self.presenceTimer = QBRTCTimer(timeInterval: kChatPresenceTimeInterval, repeat: true, queue: dispatch_get_main_queue(), completion:{
                QBChat.instance().sendPresence()
            },
            expiration: {
                if QBChat.instance().isConnected() {
                    QBChat.instance().disconnectWithCompletionBlock({ (error) -> Void in
                    })
                }
                
                if self.presenceTimer != nil {
                    self.presenceTimer?.invalidate()
                    self.presenceTimer = nil
                }
        })
    }
    
    func chatDidReconnect() {
    }
    
    //QBRTCClientDelegate
    func didReceiveNewSession(session: QBRTCSession!, userInfo: [NSObject : AnyObject]!) {
        if session == nil {
            return
        }

        if self.currentSession != nil {
            session.rejectCall(["reject":"busy"])
            return
        }

        if self.currentSession == session {
            return
        }
        
        self.currentSession = session
        
        let otherUserQuickbloxID = userInfo["startCall"] as! String
        WebServiceAPI.postDataWithURL(Constants.APINames.GetStudentInfo, withoutHeader: false, params: ["qb_id": otherUserQuickbloxID], completionBlock: {(request:NSURLRequest?, response:NSHTTPURLResponse?, json:AnyObject)->Void in
            
            let responseFromServer = JSON(json).dictionaryObject
            
            TheGlobalPoolManager.opponentUser = User()

            TheGlobalPoolManager.opponentUser?.loadDictionary(responseFromServer!["userInfo"] as! Dictionary<String, AnyObject>)
            QBRTCSoundRouter.instance().initialize()
            
            TheGlobalPoolManager.bCallerUser = false

            //present incoming call view controller
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewCon: IncomingCallViewController = storyboard.instantiateViewControllerWithIdentifier("incomingcallview") as! IncomingCallViewController
            viewCon.strOpponentUserName = (TheGlobalPoolManager.opponentUser?.username)!
            viewCon.strOpponentUserProfileUrl = (TheGlobalPoolManager.opponentUser?.profilePicUrl)!
            
            self.bIncomingCall = true
            
            UIApplication.topViewController()?.presentViewController(viewCon, animated: true, completion: nil)

            }, errBlock: {(errorString) -> Void in
        })
    }
    
    func sessionDidClose(session: QBRTCSession!) {
        if session == self.currentSession {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.currentSession = nil
            }
        }
    }
    
    func session(session: QBRTCSession!, updatedStatsReport report: QBRTCStatsReport!, forUserID userID: NSNumber!) {
    }
    
    func session(session: QBRTCSession!, userDidNotRespond userID: NSNumber!) {
        if session == self.currentSession {
            self.currentSession?.connectionStateForUser(userID)
            if  self.delegate != nil {
                self.delegate?.callErrors("User does not respond!")
            }
        }
    }
    
    func session(session: QBRTCSession!, initializedLocalMediaStream mediaStream: QBRTCMediaStream!) {
        session.localMediaStream.videoTrack.videoCapture = self.currentVideoCallViewCon?.cameraCapture
    }

    func session(session: QBRTCSession!, hungUpByUser userID: NSNumber!, userInfo: [NSObject : AnyObject]!) {
        if session == self.currentSession {
            self.currentSession?.connectionStateForUser(userID)
            if (self.currentVideoCallViewCon != nil) {
                self.currentVideoCallViewCon?.endCallProcess()
            }
        }
    }

    func session(session: QBRTCSession!, acceptedByUser userID: NSNumber!, userInfo: [NSObject : AnyObject]!) {
        if session == self.currentSession {
            self.opponentUserID = userID;
            self.currentSession?.connectionStateForUser(userID)
            
            if  self.delegate != nil {
                self.stopCallingRingToneSound()
                self.delegate?.acceptedByUser()
            }
        }
    }
    
    func session(session: QBRTCSession!, rejectedByUser userID: NSNumber!, userInfo: [NSObject : AnyObject]!) {
        if session == self.currentSession {
            self.currentSession?.connectionStateForUser(userID)
            
            if  self.delegate != nil {
                self.delegate?.callErrors("Rejected your call!")
            }
        }
    }

    func session(session: QBRTCSession!, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack!, fromUser userID: NSNumber!) {
        if session == self.currentSession {
            self.currentVideoCallViewCon?.m_opponentVideoView.setVideoTrack(videoTrack)
        }
    }

    func session(session: QBRTCSession!, startedConnectingToUser userID: NSNumber!) {
        if session == self.currentSession {
            self.currentSession?.connectionStateForUser(userID)
            
            if self.currentVideoCallViewCon != nil {
                self.currentVideoCallViewCon?.connectingActivity.hidden = true
            }
        }
    }
    
    func session(session: QBRTCSession!, connectedToUser userID: NSNumber!) {
        if session == self.currentSession {
            self.currentSession?.connectionStateForUser(userID)
            
            if self.currentVideoCallViewCon != nil {
                self.currentVideoCallViewCon?.connectingActivity.hidden = true
            }
            
            //recording start
            if (TheGlobalPoolManager.bCallerUser) {
                self.recordSoundSetting()
                self.actionStopRecording()
                self.actionStartRecording()
            }
        }
    }
    
    func session(session: QBRTCSession!, connectionClosedForUser userID: NSNumber!) {
        if session == self.currentSession {
            self.currentSession?.connectionStateForUser(userID)
            self.currentVideoCallViewCon?.m_opponentVideoView.setVideoTrack(nil)
            
            if beepTimer != nil {
                beepTimer?.invalidate()
                beepTimer = nil
            }
            
            if (TheGlobalPoolManager.bCallerUser) {
                self.actionStopRecording()
                
                //process with recorded audio
                 let audioData = NSData(contentsOfURL: self.recorder.url)
                let params = ["call_user_id": "\(TheGlobalPoolManager.opponentUser!.id)"]

                WebServiceAPI.sendMessageWithMedia(audioData, fileName: "audio.m4a", mimeType: "audio/mp4", attachParamName: "media", url: Constants.APINames.VideoCallUpload, params: params, completionBlock: {(media_link, media_type) -> Void in
                        print("%s", media_link)
                    }, errBlock: {(errorString) -> Void in
                        LoadingOverlay.shared.hideOverlayView()
                })

                
            }
            
            if  self.delegate != nil {
                self.delegate?.callErrors("Call is ended!")
            }
        }
    }
    
    func session(session: QBRTCSession!, disconnectedFromUser userID: NSNumber!) {
        if session == self.currentSession {
            self.currentSession?.connectionStateForUser(userID)
            
            if beepTimer != nil {
                beepTimer?.invalidate()
                beepTimer = nil
            }
            
            if  self.delegate != nil {
                self.delegate?.callErrors("Disconnected!")
            }
        }
    }
    
    func session(session: QBRTCSession!, disconnectedByTimeoutFromUser userID: NSNumber!) {
        if session == self.currentSession {
            self.currentSession?.connectionStateForUser(userID)
            
            if beepTimer != nil {
                beepTimer?.invalidate()
                beepTimer = nil
            }
            
            if  self.delegate != nil {
                self.delegate?.callErrors("Timeout error!")
            }
        }
    }
    
    func session(session: QBRTCSession!, connectionFailedForUser userID: NSNumber!) {
        if session == self.currentSession {
            self.currentSession?.connectionStateForUser(userID)
            
            if beepTimer != nil {
                beepTimer?.invalidate()
                beepTimer = nil
            }
            
            if  self.delegate != nil {
                self.delegate?.callErrors("Connection is failed!")
            }
        }
    }
    
    //video save
    // MARK: File Output Delegate
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        LoadingOverlay.shared.hideOverlayView()
        
        if(error != nil){
            print(error)
        }
        
        ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(outputFileURL, completionBlock: {
            (assetURL:NSURL!, error:NSError!) in
            if error != nil{
                print(error)
                
            }
            
            do {
                try NSFileManager.defaultManager().removeItemAtURL(outputFileURL)
            } catch _ {
            }
        })
        
    }

    //record audio 
    func actionStopRecording() {
        // Stop Recording
        print("User Stopping recording now")
        
        if !self.bRecording {
            return
        }
        
        self.bRecording = false
        
        recorder.stop()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        }
        catch {
            print("Failed to deactivate the AVAudioSession")
        }
    }
    
    func actionStartRecording() {
        // Stop the audio player before recording
        self.bRecording = true
        
        // Start Recording
        print("Recorder was not recording. Activating it now")
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(true)
            
        }
        catch  {
            print("Failed to activate AVAudioSession")
        }
        
        recorder.record()
    }
    
    // MARK: - AVAudioRecorder Delegate Methods
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Finished Recording")
        
    }
    

 }
