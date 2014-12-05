//
//  SignUpViewController.swift
//  remember
//
//  Created by Joseph Cheung on 4/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

@objc protocol SignUpViewControllerDelegate {
    func cancelButtonClicked()
    func createdUser()
}

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    
    weak var delegate: SignUpViewControllerDelegate?
    
    @IBOutlet weak var cameraButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
        usernameTextField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let proportion = cameraButton.frame.width / 4
        
        cameraButton.layer.cornerRadius = cameraButton.frame.size.height / 2
        
        cameraButton.layer.masksToBounds = true
        cameraButton.imageEdgeInsets = UIEdgeInsetsMake(proportion, proportion, proportion, proportion)
    }
    
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        delegate?.cancelButtonClicked()
        view.endEditing(true)
    }
    
    @IBAction func cameraButtonPressed(sender: UIButton) {
        view.endEditing(true)
    }
    
    @IBAction func confirmButtonPressed(sender: UIButton) {
        delegate?.createdUser()
        view.endEditing(true)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
