//
//  RecorderViewController.swift
//  remember
//
//  Created by Joseph Cheung on 28/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

@objc protocol RecorderViewControllerDelegate {
    optional func recorderWillStartRecording()
    optional func recorderWillFinishRecording()
    optional func recorderWillCancelRecording()
    optional func recorderDidStartRecording()
    optional func recorderDidFinishRecording(#valid: Bool)
    optional func recorderDidCancelRecording()
    optional func recorderButtonDidDragEnter()
    optional func recorderButtonDidDragExit()
}

class RecorderViewController: UIViewController, AudioRecorderDelegate {
    
    let MICROPHONE_ACCESS_DENIED = NSLocalizedString("MICROPHONE_ACCESS_DENIED", comment: "Microphone access is denied by user")
    let MICROPHONE_ACCESS_ALERT_MSG = NSLocalizedString("MICROPHONE_ACCESS_ALERT_MSG", comment: "Alert message to inform user to reset microphone access")
    
    @IBOutlet weak var recordButton: UIButton!
    weak var delegate: RecorderViewControllerDelegate?
    lazy var recorder:AudioRecorder = {
        let audioRecorder = AudioRecorder()
        audioRecorder.delegate = self
        return audioRecorder
        }()

    @IBAction func recordButtonTouchedDown(sender: UIButton) {
        if let recorderWillStartRecording = delegate?.recorderWillStartRecording {
            recorderWillStartRecording()
        }
        
        recorder.startDate = NSDate()
        recorder.recordAudio()
        
        if let recorderDidStartRecording = delegate?.recorderDidStartRecording {
            recorderDidStartRecording()
        }
    }
    
    @IBAction func recordButtonTouchedUpInside(sender: UIButton) {
        finishRecording()
    }
    
    @IBAction func recordButtonTouchedUpOutside(sender: UIButton) {
        stopRecording()
    }
    
    @IBAction func recordButtonTouchedDragEnter(sender: UIButton) {
        if let recordButtonDidDragEnter = delegate?.recorderButtonDidDragEnter {
            recordButtonDidDragEnter()
        }
    }
    
    @IBAction func recordButtonTouchedDragExit(sender: UIButton) {
        if let recordButtonDidDragExit = delegate?.recorderButtonDidDragExit {
            recordButtonDidDragExit()
        }
    }
    
    func stopRecording() {
        if let recorderWillCancelRecording = delegate?.recorderWillCancelRecording {
            recorderWillCancelRecording()
        }
        
        recorder.stopRecordingAudio()
        
        if let recorderDidCancelRecording = delegate?.recorderDidCancelRecording {
            recorderDidCancelRecording()
        }
    }
    
    func finishRecording() {
        if let recorderWillFinishRecording = delegate?.recorderWillFinishRecording {
            recorderWillFinishRecording()
        }
        
        recorder.finishRecordingAudio()
        
        if let recorderDidFinishRecording = delegate?.recorderDidFinishRecording {
            recorderDidFinishRecording(valid: recorder.validRecord)
        }
    }
    
    //MARK: - AudioRecorderDelegate
    
    func microphoneAccssDenied() {
        let controller = UIAlertController(title: MICROPHONE_ACCESS_DENIED, message: MICROPHONE_ACCESS_ALERT_MSG, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        controller.addAction(cancelAction)
        presentViewController(controller, animated: true) { [weak self]() -> Void in
            if let weakself = self {
                weakself.recordButton.enabled = false
            }
        }
    }
}
