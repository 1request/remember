//
//  FeedbackViewController.swift
//  remember
//
//  Created by Joseph Cheung on 25/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    lazy var hudView = HUD()
    let audioRecorder = AudioRecorder()
    let RECORDING_FEEDBACK = NSLocalizedString("RECORDING_FEEDBACK", comment: "inform user of feedback is being recorded")
    let SEND_FEEDBACK = NSLocalizedString("SEND_FEEDBACK", comment: "inform user to fill in name and hit submit")
    let INVALID_FEEDBACK = NSLocalizedString("INVALID_FEEDBACK", comment: "inform user feedback record is too short")
    
    var recorderViewController: RecorderViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        submitButton.enabled = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let recorderVC = segue.destinationViewController as? RecorderViewController {
            recorderViewController = recorderVC
            recorderViewController?.delegate = self
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func nameTextFieldEditingChanged(sender: UITextField) {
        if countElements(sender.text.trimWhiteSpace()) > 0 {
            submitButton.enabled = true
        } else {
            submitButton.enabled = false
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
        Mixpanel.sharedInstance().track("feedbackSent")
    }
    
    func microphoneAccssDenied(alert: UIAlertController) {
        presentViewController(alert, animated: true, completion: nil)
    }
}

extension FeedbackViewController: RecorderViewControllerDelegate {
    func recorderWillStartRecording() {
        hudView = HUD.hudInView(view)
        hudView.text = SLIDE_UP_TO_CANCEL
    }
    
    func recorderWillFinishRecording() {
        hudView.removeFromSuperview()
    }
    
    func recorderDidFinishRecording(#valid: Bool) {
        if valid {
            submitButton.hidden = false
            nameTextField.hidden = false
            informationLabel.text = SEND_FEEDBACK
        } else {
            informationLabel.text = INVALID_FEEDBACK
        }
    }
    
    func recorderWillCancelRecording() {
        hudView.removeFromSuperview()
    }
    
    func recorderButtonDidDragEnter() {
        hudView.text = SLIDE_UP_TO_CANCEL
        hudView.setNeedsDisplay()
    }
    
    func recorderButtonDidDragExit() {
        hudView.text = RELEASE_TO_CANCEL
        hudView.setNeedsDisplay()
    }
}
