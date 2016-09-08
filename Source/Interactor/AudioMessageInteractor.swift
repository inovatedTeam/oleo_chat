//
//  AudioMessageInteractor.swift
//  ready
//
//  Created by Patrick Sheehan on 1/15/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit
import AVFoundation

var recorder: AVAudioRecorder?
var player: AVAudioPlayer?

class AudioMessageInteractor: NSObject, AVAudioRecorderDelegate {
    
    
    class func configureRecorder() {
        
        if recorder == nil {
            

            // Set the audio file
            let pathComponents: [String] = [NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!, "MyAudioMemo.m4a"]
            
            let outputFileURL = NSURL.fileURLWithPathComponents(pathComponents)
            
            // Setup audio session
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
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
                
//                recorder!.delegate = self
                recorder!.meteringEnabled = true
                recorder!.prepareToRecord()
            }
            catch {
                print("Failed to setup AVAudioRecorder")
            }
        }
        else {
            print("AVRecorder was already initialized")
        }
        
    }
    
    
    class func startRecording() {
        
        self.configureRecorder()
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(true)

        }
        catch  {
            print("Failed to activate AVAudioSession")
        }
        
        recorder!.record()

    }
    
    
    
    
    
//    // MARK: - IB Outlets
//    @IBOutlet var recordPauseButton: UIButton!
//    @IBOutlet var stopButton: UIButton!
//    @IBOutlet var playButton: UIButton!
//    
//    // MARK: - View Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Do any additional setup after loading the view.
//        
//        // Disable Stop/Play button when application launches
//        stopButton.enabled = false
//        playButton.enabled = false
//        
//        // Set the audio file
//        let pathComponents: [String] = [NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!, "MyAudioMemo.m4a"]
//        
//        let outputFileURL = NSURL.fileURLWithPathComponents(pathComponents)
//        
//        // Setup audio session
//        let session = AVAudioSession.sharedInstance()
//        do {
//            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
//        }
//        catch {
//            print("Failed to setup AVAudioSession")
//        }
//        
//        // Define the recorder setting
//        var recordSetting = [String: AnyObject]()
//        recordSetting[AVFormatIDKey] = NSNumber(unsignedInt: kAudioFormatMPEG4AAC)
//        recordSetting[AVSampleRateKey] = NSNumber(float:44100.0)
//        recordSetting[AVNumberOfChannelsKey] = NSNumber(int: 2)
//        
//        // Initiate and prepare the recorder
//        do {
//            try recorder = AVAudioRecorder(URL: outputFileURL!, settings: recordSetting)
//            
//            recorder.delegate = self
//            recorder.meteringEnabled = true
//            recorder.prepareToRecord()
//        }
//        catch {
//            print("Failed to setup AVAudioRecorder")
//        }
//        
//    }
//    
//    // MARK: - IB Actions
//    @IBAction func recordPauseTapped(sender: AnyObject) {
//        
//        // Stop the audio player before recording
//        if let p = player {
//            if p.playing {
//                print("AudioPlayer was playing. Stopping it now")
//                player!.stop()
//            }
//        }
//        
//        if !recorder.recording {
//            // Start Recording
//            print("Recorder was not recording. Activating it now")
//            
//            let session = AVAudioSession.sharedInstance()
//            do {
//                try session.setActive(true)
//                
//            }
//            catch  {
//                print("Failed to activate AVAudioSession")
//            }
//            
//            recorder.record()
//            recordPauseButton.setTitle("Pause", forState: UIControlState.Normal)
//            
//        } else {
//            // Pause recording
//            print("Recorder was already recording. Pausing it now")
//            
//            recorder!.pause()
//            recordPauseButton.setTitle("Record", forState: UIControlState.Normal)
//        }
//        
//        
//        stopButton.enabled = true
//        playButton.enabled = false
//    }
//    
//    @IBAction func stopTapped(sender: AnyObject) {
//        
//        // Stop Recording
//        print("User Stopping recording now")
//        
//        recorder.stop()
//        
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setActive(false)
//        }
//        catch {
//            print("Failed to deactivate the AVAudioSession")
//        }
//    }
//    
//    @IBAction func playTapped(sender: AnyObject) {
//        
//        // Play Recording
//        print("Playing recording now")
//        
//        if !recorder.recording {
//            print("Recorder was not recording. Initializing AVAudioPlayer now")
//            do {
//                try player = AVAudioPlayer(contentsOfURL: recorder!.url)
//                player!.delegate = self
//                player!.play()
//            }
//            catch {
//                print("Failed to initialize AVAudioPlayer with URL=\(recorder!.url)")
//            }
//        }
//        else {
//            print("Whoops! The Recording seems to still be recording")
//        }
//    }
//    
//    // MARK: - AVAudioRecorder Delegate Methods
//    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
//        print("Finished Recording")
//        
//        recordPauseButton.setTitle("Record", forState: .Normal)
//        
//        stopButton.enabled = false
//        playButton.enabled = true
//    }
//    
//    
//    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
//        print("Finished Playing")
//        
//        
//        //TODO: Show an alert here!
//        
//    }

    
    
}
