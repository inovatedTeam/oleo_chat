//
//  VideoMessageViewController.swift
//  ready
//
//  Created by Patrick Sheehan on 1/14/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

let maxVideoRecordingTime: Float = 30.0

protocol VideoMessageViewControllerDelegate {
    func checkVideo(viewCon:VideoMessageViewController, recordVideoPath: NSURL)
}

class VideoMessageViewController: BaseViewController, AVCaptureFileOutputRecordingDelegate {

    @IBOutlet weak var m_cameraView: UIView!
    @IBOutlet weak var m_recordingTimeIndicator: NSLayoutConstraint!
    @IBOutlet weak var m_viewRecordingTimeIndicator: UIView!
    
    var sessionQueue: dispatch_queue_t!

    var delegate: VideoMessageViewControllerDelegate? = nil
    var bRecording: Bool = false
    var fTimeIndicator: Float = 0.0
    
    var recordingTimer: NSTimer? = nil
    
    let captureSession = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput?
    var audioDeviceInput: AVCaptureDeviceInput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var movieFileOutput = AVCaptureMovieFileOutput()
    var flashMode: AVCaptureFlashMode = .Off

    let outputFilePath  = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("movie.mov")

    @IBOutlet weak var m_btnRecord: UIButton!
    @IBOutlet weak var m_btnFlash: UIButton!
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let sessionQueue: dispatch_queue_t = dispatch_queue_create("session queue",DISPATCH_QUEUE_SERIAL)
        self.sessionQueue = sessionQueue
    
        self.cameraSetting()
    }
 
    override func viewDidLayoutSubviews() {
        //make user interface
        InterfaceManager.addBorderToView(self.m_btnRecord, toCorner: .AllCorners, cornerRadius: CGSizeMake(self.m_btnRecord.bounds.size.height / 2.0, self.m_btnRecord.bounds.size.height / 2.0), withColor: UIColor.redColor(), borderSize: 0.0)
        
        if previewLayer != nil {
            previewLayer!.frame = self.m_cameraView.layer.bounds
        }
    }

    func cameraSetting () {
        // Do any additional setup after loading the view, typically from a nib.
        self.m_recordingTimeIndicator.constant = 0
        self.m_viewRecordingTimeIndicator.layoutIfNeeded()
        
        self.m_btnRecord.backgroundColor = UIColor.redColor()

        self.m_btnFlash.setImage(UIImage(named: "SwitchFlash_off.png"), forState: .Normal)
        self.m_btnRecord.backgroundColor = UIColor.redColor()

        //camera settings
        captureSession.sessionPreset = AVCaptureSessionPresetMedium
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the front camera
                if(device.position == AVCaptureDevicePosition.Front) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        self.beginSession()
                    }
                }
            }
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

    func setFlashMode(flashMode: AVCaptureFlashMode, device: AVCaptureDevice){
        
        if device.hasFlash && device.isFlashModeSupported(flashMode) {
            var error: NSError? = nil
            do {
                try device.lockForConfiguration()
                device.flashMode = flashMode
                device.unlockForConfiguration()
                
            } catch let error1 as NSError {
                error = error1
                print(error)
            }
        }
        
    }

    func configureDevice() {
        if let device = captureDevice {
            if let _ = try? device.lockForConfiguration()
            {
//                device.focusMode = .Locked
                device.unlockForConfiguration()
            }
        }
        
    }

    func touchPercent(touch : UITouch) -> CGPoint {
        // Get the dimensions of the screen in points
        let screenSize = UIScreen.mainScreen().bounds.size
        
        // Create an empty CGPoint object set to 0, 0
        var touchPer = CGPointZero
        
        // Set the x and y values to be the value of the tapped position, divided by the width/height of the screen
        touchPer.x = touch.locationInView(self.view).x / screenSize.width
        touchPer.y = touch.locationInView(self.view).y / screenSize.height
        
        // Return the populated CGPoint
        return touchPer
    }
    
    func updateDeviceSettings(focusValue : Float, isoValue : Float) {
        if let device = captureDevice {
            if let _ = try? device.lockForConfiguration() {
//                device.setFocusModeLockedWithLensPosition(focusValue, completionHandler: {(time) -> Void in
//                })
                
                // Adjust the iso to clamp between minIso and maxIso based on the active format
                let minISO = device.activeFormat.minISO
                let maxISO = device.activeFormat.maxISO
                let clampedISO = isoValue * (maxISO - minISO) + minISO
                
                device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO: clampedISO, completionHandler: { (time) -> Void in
                    //
                })
                
                device.unlockForConfiguration()
            }
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let position :CGPoint = self.touchPercent(touch)
            updateDeviceSettings(Float(position.x), isoValue: Float(position.y))
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let position :CGPoint = self.touchPercent(touch)
            updateDeviceSettings(Float(position.x), isoValue: Float(position.y))
        }
    }

    func beginSession() {
        configureDevice()
        
        if let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) {
            captureSession.addInput(deviceInput)
        } else {
            NSLog("didn't begin session")
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
        
        // Configure Movie output
        let movieFileOutput: AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(movieFileOutput) {
            captureSession.addOutput(movieFileOutput)
            
            let connection: AVCaptureConnection? = movieFileOutput.connectionWithMediaType(AVMediaTypeVideo)
            let stab = connection?.supportsVideoStabilization
            if (stab != nil) {
                connection!.preferredVideoStabilizationMode = .Auto
            }
            
            self.movieFileOutput = movieFileOutput
        }

        // Add Video input to capture session
        if captureSession.canAddInput(videoDeviceInput){
            captureSession.addInput(videoDeviceInput)
            self.videoDeviceInput = videoDeviceInput
        }
        
        // Add Audio input to capture session
        if captureSession.canAddInput(audioDeviceInput) {
            captureSession.addInput(audioDeviceInput)
            self.audioDeviceInput = audioDeviceInput
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.m_cameraView.layer.addSublayer(previewLayer!)
        previewLayer!.frame = self.m_cameraView.layer.bounds
        
        captureSession.startRunning()
    }
 
    @IBAction func actionCloseView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func actionCheckVideo(sender: AnyObject) {
        self.delegate?.checkVideo(self, recordVideoPath: self.outputFilePath)
    }
    
    
    @IBAction func actionSwitchCamera(sender: AnyObject) {
        dispatch_async(self.sessionQueue, {
            
            let currentVideoDevice:AVCaptureDevice = self.videoDeviceInput!.device
            let currentPosition: AVCaptureDevicePosition = currentVideoDevice.position
            var preferredPosition: AVCaptureDevicePosition = AVCaptureDevicePosition.Unspecified
            
            switch currentPosition{
            case AVCaptureDevicePosition.Front:
                preferredPosition = AVCaptureDevicePosition.Back
            case AVCaptureDevicePosition.Back:
                preferredPosition = AVCaptureDevicePosition.Front
            case AVCaptureDevicePosition.Unspecified:
                preferredPosition = AVCaptureDevicePosition.Front
                
            }
            
            let device:AVCaptureDevice = self.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: preferredPosition)
            
            var videoDeviceInput: AVCaptureDeviceInput?
            
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: device)
            } catch _ as NSError {
                videoDeviceInput = nil
            } catch {
                fatalError()
            }
            
            self.captureSession.beginConfiguration()
            
            let currentVideoDeviceInput: AVCaptureDeviceInput = self.captureSession.inputs[0] as! AVCaptureDeviceInput
            self.captureSession.removeInput(currentVideoDeviceInput)
            
            self.captureSession.addInput(videoDeviceInput)
            self.videoDeviceInput = videoDeviceInput
            
            self.captureSession.commitConfiguration()
            
        })
    }

    @IBAction func actionSwitchFlash(sender: AnyObject) {
        if self.flashMode == .Off
        {
            self.flashMode = .On
            self.m_btnFlash.setImage(UIImage(named: "SwitchFlash_on.png"), forState: .Normal)
        } else if self.flashMode == .On {
            self.flashMode = .Auto
            self.m_btnFlash.setImage(UIImage(named: "SwitchFlash_auto.png"), forState: .Normal)
        } else if self.flashMode == .Auto {
            self.flashMode = .Off
            self.m_btnFlash.setImage(UIImage(named: "SwitchFlash_off.png"), forState: .Normal)
        }
        
        self.setFlashMode(self.flashMode, device: self.videoDeviceInput!.device)
    }
    
    func timerProc() {
        if !self.bRecording{
            return
        }
        
        if self.fTimeIndicator >= maxVideoRecordingTime {
            self.actioStopVideoRecording(self.m_btnRecord)
            return
        }
        
        self.fTimeIndicator += 0.01
        
        self.m_recordingTimeIndicator.constant = CGFloat(self.fTimeIndicator / maxVideoRecordingTime) * self.view.bounds.size.width
        self.m_viewRecordingTimeIndicator.layoutIfNeeded()
    }
    
    @IBAction func actionStartRecording(sender: AnyObject) {
        NSLog("start recording")

        self.fTimeIndicator = 0.0
        
        self.m_recordingTimeIndicator.constant = 0
        self.m_viewRecordingTimeIndicator.layoutIfNeeded()

        self.bRecording = true
        self.recordingTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(VideoMessageViewController.timerProc), userInfo: nil, repeats: true)
        
        self.m_btnRecord.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.3)
        
        self.movieFileOutput.connectionWithMediaType(AVMediaTypeVideo).videoOrientation =
            AVCaptureVideoOrientation(rawValue: self.previewLayer!.connection.videoOrientation.rawValue )!
        
        self.movieFileOutput.startRecordingToOutputFileURL( self.outputFilePath, recordingDelegate: self)
    }
    
    @IBAction func actioStopVideoRecording(sender: AnyObject) {
        NSLog("end recording")
        if !self.bRecording {
            return
        }
        
        self.bRecording = false
        
        if self.recordingTimer != nil {
            self.recordingTimer?.invalidate()
            self.recordingTimer = nil
        }
        
        self.m_btnRecord.backgroundColor = UIColor.redColor()

        self.movieFileOutput.stopRecording()

        LoadingOverlay.shared.showOverlay(self.view)
    }
    
    // MARK: File Output Delegate
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        LoadingOverlay.shared.hideOverlayView()
        
        if(error != nil){
            print(error)
        }
        
        /*
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
        */
        
    }

}