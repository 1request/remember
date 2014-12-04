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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
        usernameTextField.delegate = self
    }
    
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        delegate?.cancelButtonClicked()
    }
    
    @IBAction func cameraButtonPressed(sender: UIButton) {
    }
    
    @IBAction func confirmButtonPressed(sender: UIButton) {
        delegate?.createdUser()
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
