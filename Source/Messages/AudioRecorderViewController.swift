//
//  AudioRecorderViewController.swift
//  ready
//
//  Created by Patrick Sheehan on 1/13/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit
import AVFoundation

let maxAudioRecordingTime: Float = 60.0

protocol AudioRecorderViewControllerDelegate {
    func dismissAudioRecordViewCon(viewCon: AudioRecorderViewController, closeMode: Bool, audioPath: NSURL?)
}

class AudioRecorderViewController: BaseViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    // MARK: - Variables
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer?
    
    var delegate: AudioRecorderViewControllerDelegate? = nil
    
    var bRecording: Bool = false
    var recordingTimer: NSTimer? = nil
    var fTimeIndicator: Float = 0.0
    
    @IBOutlet weak var m_viewProgressCanvas: UIView!
    @IBOutlet weak var m_recordingTimeIndicator: NSLayoutConstraint!
    @IBOutlet weak var m_viewRecordingTimeIndicator: UIView!
    
    @IBOutlet weak var m_btnRecord: UIButton!
    @IBOutlet weak var m_btnPlayAndStopAudio: UIButton!
    
    // MARK: - IB Outlets
    
    @IBAction func actionPlayAndStopAudio(sender: AnyObject) {
        // Play Recording
        print("Playing recording now")
        if (self.player != nil)
        {
            if self.player!.playing {
                print("AudioPlayer was playing. Stopping it now")
                self.player!.stop()
                
                self.setPlayAndStopButton(true)
                return
            }
        }
        
        do {
            try self.player = AVAudioPlayer(contentsOfURL: recorder!.url)
            self.player!.delegate = self
            self.player!.play()
            
            self.setPlayAndStopButton(false)
        }
        catch {
            print("Failed to initialize AVAudioPlayer with URL=\(recorder!.url)")
        }
    }
    
    @IBAction func actionClose(sender: AnyObject) {
        self.delegate?.dismissAudioRecordViewCon(self, closeMode: false, audioPath: nil)
    }
    
    @IBAction func actionCheck(sender: AnyObject) {
        self.delegate?.dismissAudioRecordViewCon(self, closeMode: true, audioPath: recorder!.url)
    }
    
    func setPlayAndStopButton(type: Bool) {
        self.m_btnPlayAndStopAudio.setImage(UIImage(named: type ? "play_audio.png" : "stop_audio.png"), forState: .Normal)
    }
    
    func timerProc() {
        if !self.bRecording{
            return
        }
        
        if self.fTimeIndicator >= maxAudioRecordingTime {
            self.actionStopRecording(self.m_btnRecord)
            return
        }
        
        self.fTimeIndicator += 0.01
        
        self.m_recordingTimeIndicator.constant = CGFloat(self.fTimeIndicator / maxAudioRecordingTime) * self.m_viewProgressCanvas.bounds.size.width
        self.m_viewRecordingTimeIndicator.layoutIfNeeded()
    }
    
    @IBAction func actionStopRecording(sender: AnyObject) {
        // Stop Recording
        print("User Stopping recording now")
        
        if !self.bRecording {
            return
        }
        
        self.bRecording = false
        if self.recordingTimer != nil {
            self.recordingTimer?.invalidate()
            self.recordingTimer = nil
        }

        self.m_btnRecord.backgroundColor = UIColor.redColor()

        recorder.stop()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        }
        catch {
            print("Failed to deactivate the AVAudioSession")
        }
        
        self.m_btnPlayAndStopAudio.enabled = true
    }
    
    @IBAction func actionStartRecording(sender: AnyObject) {
        // Stop the audio player before recording
        if let p = player {
            if p.playing {
                print("AudioPlayer was playing. Stopping it now")
                player!.stop()
                self.setPlayAndStopButton(true)
            }
        }

        self.bRecording = true
        self.fTimeIndicator = 0.0
        self.m_recordingTimeIndicator.constant = 0
        self.view.layoutIfNeeded()
        
        self.recordingTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(AudioRecorderViewController.timerProc), userInfo: nil, repeats: true)
        
        self.m_btnRecord.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.3)

        self.m_btnPlayAndStopAudio.enabled = false
        
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
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setPlayAndStopButton(true)
        self.m_btnPlayAndStopAudio.enabled = false
        
        self.m_recordingTimeIndicator.constant = 0
        self.view.layoutIfNeeded()
        
        // Set the audio file
        let pathComponents: [String] = [NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!, "audio.m4a"]
        
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
        
            recorder.delegate = self
            recorder.meteringEnabled = true
            recorder.prepareToRecord()
        }
        catch {
            print("Failed to setup AVAudioRecorder")
        }
        
    }

    override func viewDidLayoutSubviews() {
        self.m_btnRecord.backgroundColor = UIColor.redColor()
        
        InterfaceManager.addBorderToView(self.m_btnRecord, toCorner: .AllCorners, cornerRadius: CGSizeMake(self.m_btnRecord.bounds.size.height / 2.0, self.m_btnRecord.bounds.size.height / 2.0), withColor: UIColor.redColor(), borderSize: 0.0)
        InterfaceManager.addBorderToView(self.m_viewProgressCanvas, toCorner: .AllCorners, cornerRadius: CGSizeMake(self.m_viewProgressCanvas.bounds.size.height / 2.0, self.m_viewProgressCanvas.bounds.size.height / 2.0), withColor: UIColor.redColor(), borderSize: 2.0)
    }
    
    // MARK: - AVAudioRecorder Delegate Methods
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Finished Recording")

        self.m_btnPlayAndStopAudio.enabled = true
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        self.setPlayAndStopButton(true)
    }

}
