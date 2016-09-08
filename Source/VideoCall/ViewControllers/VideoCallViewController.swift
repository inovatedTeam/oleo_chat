//
//  VideoCallViewController.swift
//  VideoChat
//
//  Created by Admin on 25/02/16.
//  Copyright © 2016 RonnieAlex. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

let kRefreshTimeInterval: NSTimeInterval = 1.0

class VideoCallViewController: UIViewController, OutComingCallViewControllerDelegate {
    @IBOutlet weak var m_opponentVideoView: QBRTCRemoteVideoView!
    @IBOutlet weak var m_myVideoView: UIView!
    
    @IBOutlet weak var connectingActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var m_btnMuteSound: UIButton!
    @IBOutlet weak var m_btnEndCall: UIButton!
    @IBOutlet weak var m_btnSwitchCamera: UIButton!

    var bRecording: Bool = false
    
    var videoLayer: AVCaptureVideoPreviewLayer? = nil
    var cameraCapture: QBRTCCameraCapture? = nil

    var videoDeviceInput: AVCaptureDeviceInput?
    var audioDeviceInput: AVCaptureDeviceInput?
    var movieFileOutput = AVCaptureMovieFileOutput()

    let outputFilePath  = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("movie.mov")

    //variables for opponent user info
    var bOutComingCall: Bool = false
    var strOpponentUserName: String = ""
    var strOpponentUserProfileUrl: String = ""
    var opponentUserID: NSNumber? = nil
    //---------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        TheVideoCallManager.configureGUI()

        TheVideoCallManager.currentVideoCallViewCon = self
        
        self.cameraCapture = QBRTCCameraCapture(videoFormat: QBRTCVideoFormat.defaultFormat(), position: .Front)
        //setupVideoSaveSession()
        self.cameraCapture?.startSession()
        QBRTCSoundRouter.instance().initialize()
        
        if bOutComingCall {
            TheVideoCallManager.startCall()
        } else {
            TheVideoCallManager.acceptCall()
        }
    }

    func setupVideoSaveSession() {
        // Configure Movie output
        let movieFileOutput: AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
        if (self.cameraCapture?.captureSession.canAddOutput(movieFileOutput) == true) {
            self.cameraCapture?.captureSession.addOutput(movieFileOutput)
            
            let connection: AVCaptureConnection? = movieFileOutput.connectionWithMediaType(AVMediaTypeVideo)
            let stab = connection?.supportsVideoStabilization
            if (stab != nil) {
                connection!.preferredVideoStabilizationMode = .Auto
            }
            
            self.movieFileOutput = movieFileOutput
        }
        
        // Configure Audio input
        let audioDevice: AVCaptureDevice! = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        var audioDeviceInput: AVCaptureDeviceInput?
        do {
            audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            self.audioDeviceInput = audioDeviceInput
        } catch _ as NSError {
            audioDeviceInput = nil
            self.audioDeviceInput = audioDeviceInput
        } catch {
            fatalError()
        }
        
        // Configure Video input
        let videoDevice: AVCaptureDevice! = self.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: AVCaptureDevicePosition.Front)
        var videoDeviceInput: AVCaptureDeviceInput?
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            self.videoDeviceInput = videoDeviceInput
        } catch _ as NSError {
            videoDeviceInput = nil
            self.videoDeviceInput = videoDeviceInput
        } catch {
            fatalError()
        }

        // Add Video input to capture session
        if (self.cameraCapture?.captureSession.canAddInput(videoDeviceInput) == true){
            self.cameraCapture?.captureSession.addInput(videoDeviceInput)
            self.videoDeviceInput = videoDeviceInput
        }
        
        // Add Audio input to capture session
        if (self.cameraCapture?.captureSession.canAddInput(audioDeviceInput) == true) {
            self.cameraCapture?.captureSession.addInput(audioDeviceInput)
            self.audioDeviceInput = audioDeviceInput
        }
    }
    
    func deviceWithMediaType(mediaType: String, preferringPosition:AVCaptureDevicePosition)->AVCaptureDevice {
        
        var devices = AVCaptureDevice.devicesWithMediaType(mediaType);
        var captureDevice: AVCaptureDevice = devices[0] as! AVCaptureDevice;
        
        for device in devices{
            if device.position == preferringPosition{
                captureDevice = device as! AVCaptureDevice
                break
            }
        }
        
        return captureDevice
    }

    override func viewWillAppear(animated: Bool) {
        if bOutComingCall {
            //add outcoming view controller
            let viewCon: OutComingCallViewController = self.storyboard?.instantiateViewControllerWithIdentifier("outcomingcallview") as! OutComingCallViewController
            viewCon.strOpponentUserName = self.strOpponentUserName
            viewCon.strOpponentUserProfileUrl = self.strOpponentUserProfileUrl
            viewCon.delegate = self
            
            self.addChildViewController(viewCon)
            self.view.addSubview(viewCon.view)
            viewCon.didMoveToParentViewController(self)
        }
    }
    
    func removeOutComingViewCon(viewCon: OutComingCallViewController) {
        viewCon.didMoveToParentViewController(nil)
        viewCon.view.removeFromSuperview()
        viewCon.removeFromParentViewController()
        
        self.adjustMyVideoView()
    }
    
    func setOpponentVideoView() {
        let remoteVideoTrack: QBRTCVideoTrack = (TheVideoCallManager.currentSession?.remoteVideoTrackWithUserID(TheVideoCallManager.opponentUserID))!
        self.m_opponentVideoView.setVideoTrack(remoteVideoTrack)
    }
    
    func adjustMyVideoView() {
        self.cameraCapture?.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
        self.cameraCapture?.previewLayer.frame = self.m_myVideoView.bounds
        self.m_myVideoView.layer.insertSublayer((self.cameraCapture?.previewLayer)!, atIndex: 0)
    }
    
    override func viewDidLayoutSubviews() {
        self.adjustMyVideoView()
        
        InterfaceManager.makeRadiusControl(self.m_btnEndCall, cornerRadius:self.m_btnEndCall.bounds.size.width * 0.5, withColor: UIColor.whiteColor(), borderSize: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionSwitchCamera(sender: AnyObject) {
        let position: AVCaptureDevicePosition = (self.cameraCapture?.currentPosition())!
        let newPosition: AVCaptureDevicePosition = position == .Back ? .Front : .Back
        
        if ((self.cameraCapture?.hasCameraForPosition(newPosition)) != nil) {
            let animation: CAAnimation = CAAnimation()
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

            self.m_myVideoView.layer.addAnimation(animation, forKey: nil)
            self.cameraCapture?.selectCameraPosition(newPosition)
        }
    }
  
    func endCallProcess () {
        //self.stopRecording()
        
        TheVideoCallManager.endCall()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func actionEndCall(sender: AnyObject) {
        self.endCallProcess()
    }

    @IBAction func actionMuteSound(sender: AnyObject) {
        TheVideoCallManager.muteSound()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // =========================================================================
    // MARK: - RPScreenRecorderDelegate
    func startRecording() {
        // start recording
        if (self.bRecording) {
            return
        }
        
        self.bRecording = true
        
        self.movieFileOutput.connectionWithMediaType(AVMediaTypeVideo).videoOrientation =
            AVCaptureVideoOrientation(rawValue: (self.cameraCapture!.previewLayer!.connection.videoOrientation.rawValue) )!
        
        self.movieFileOutput.startRecordingToOutputFileURL( self.outputFilePath, recordingDelegate: TheVideoCallManager)

     }
    
    func stopRecording() {
        if (!self.bRecording) {
            return
        }
     
        self.bRecording = false
        
        self.movieFileOutput.stopRecording()
        
        self.cameraCapture?.stopSession()
    }
}
