//
//  FeedbackViewController.swift
//  remember
//
//  Created by Joseph Cheung on 25/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, UITextFieldDelegate, AudioRecorderDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    var hudView = HUD()
    let audioRecorder = AudioRecorder()
    let RECORDING_FEEDBACK = NSLocalizedString("RECORDING_FEEDBACK", comment: "inform user of feedback is being recorded")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        submitButton.enabled = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text == "" {
            submitButton.enabled = false
        } else {
            submitButton.enabled = true
        }
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func recordButtonTouchedDown(sender: UIButton) {
        audioRecorder.startDate = NSDate()
        audioRecorder.recordAudio()
        hudView = HUD.hudInView(view)
        hudView.text = RECORDING_FEEDBACK
    }
    
    @IBAction func recordButtonTouchedUpInside(sender: UIButton) {
        audioRecorder.finishRecordingAudio()
        hudView.removeFromSuperview()
        if audioRecorder.validRecord {
            nameTextField.hidden = false
            submitButton.hidden = false
        }
    }
    
    @IBAction func submitButtonPressed(sender: UIButton) {
        let audioData = NSData(contentsOfURL: audioRecorder.url)!
        let data = (key: "audio", data: audioData, type: "audio/x-m4a", filename: "feedback.m4a")
        let id = UIDevice.currentDevice().identifierForVendor.UUIDString
        let name = nameTextField.text
        let parameters: [String: String] = ["name": name, "deviceId": id, "deviceType": UIDevice.currentDevice().model]
        APIManager.postMultipartData(data, parameters: parameters, url: NSURL(string: kFeedbackPOSTURL)!)
        navigationController?.popViewControllerAnimated(true)
    }
    
    func microphoneAccssDenied(alert: UIAlertController) {
        presentViewController(alert, animated: true, completion: nil)
    }
}
