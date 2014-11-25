//
//  AudioRecorder.swift
//  remember
//
//  Created by Joseph Cheung on 25/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol AudioRecorderDelegate {
    func microphoneAccssDenied(alert: UIAlertController)
}

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    let kMinimumRecordLength = 1.0
    lazy var startDate = NSDate()
    lazy var timer = NSTimer()
    lazy var timeInterval = NSTimeInterval()
    var url: NSURL
    var micAvailable = false
    var validRecord = false
    let session = AVAudioSession.sharedInstance()
    
    weak var delegate: AudioRecorderDelegate?
    
    let MICROPHONE_ACCESS_DENIED = NSLocalizedString("MICROPHONE_ACCESS_DENIED", comment: "Microphone access is denied by user")
    let MICROPHONE_ACCESS_ALERT_MSG = NSLocalizedString("MICROPHONE_ACCESS_ALERT_MSG", comment: "Alert message to inform user to reset microphone access")

    override init() {
        url = recorder.url
        super.init()
        configureAudioSession()
        checkMicrophoneAccess()
    }
    
    var recorder: AVAudioRecorder = {
        let kApplicationPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last! as String
        let path = "\(kApplicationPath)/memo.m4a"
        let fileURL = NSURL(fileURLWithPath: path)
        let settings = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2
        ]
        var error: NSError?
        var recorder = AVAudioRecorder(URL: fileURL, settings: settings, error: &error)
        if let e = error {
            println("error initializing recorder: \(e)")
        }
        else {
            recorder.meteringEnabled = true
            recorder.prepareToRecord()
        }
        return recorder
    }()
    
    func recordAudio () {
        checkMicrophoneAccess()
        if micAvailable {
            recorder.record()
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
        }
    }
    
    func checkMicrophoneAccess() {
        if session.respondsToSelector("requestRecordPermission:") {
            session.requestRecordPermission { [unowned self] (granted) -> Void in
                if !granted {
                    let controller = UIAlertController(title: self.MICROPHONE_ACCESS_DENIED, message: self.MICROPHONE_ACCESS_ALERT_MSG, preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                    controller.addAction(cancelAction)
                    self.delegate?.microphoneAccssDenied(controller)
                    self.micAvailable = false
                } else {
                    self.micAvailable = true
                }
            }
        }

    }
    
    func configureAudioSession() {
        var error: NSError?
        
        if !session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: &error) {
            println("could not set session category")
            if let e = error {
                println("set session category error: \(e.localizedDescription)")
            }
        }
        
        if !session.setActive(true, error: &error) {
            println("could not activate session")
            if let e = error {
                println("activate session error: \(e.localizedDescription)")
            }
        }
        
        if !isHeadsetPluggedIn() {
            if !session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker, error: &error) {
                println("could not override output audio port to speaker")
                if let e = error {
                    println("override output audio port error: \(e.localizedDescription)")
                }
            }
        } else {
            if !session.overrideOutputAudioPort(AVAudioSessionPortOverride.None, error: &error) {
                println("could not override output audio port to none")
                if let e = error {
                    println("override output audio port error: \(e.localizedDescription)")
                }
            }
        }
    }
    
    func isHeadsetPluggedIn() -> Bool {
        let route = AVAudioSession.sharedInstance().currentRoute
        if route.outputs != nil {
            for object in route.outputs {
                if let desc = object as? AVAudioSessionPortDescription {
                    if desc.portType == AVAudioSessionPortHeadphones {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func updateTimer () {
        timeInterval = NSDate().timeIntervalSinceDate(startDate)
    }
    
    func finishRecordingAudio () {
        Mixpanel.sharedInstance().track("audioRecorded")
        
        stopRecordingAudio()
        if timeInterval > kMinimumRecordLength {
            validRecord = true
        }
        else {
            validRecord = false
        }
        timeInterval = 0
    }
    
    func stopRecordingAudio () {
        recorder.stop()
        timer.invalidate()
    }
}
