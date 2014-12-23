//
//  SignUpView.swift
//  remember
//
//  Created by Joseph Cheung on 13/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

protocol SignUpViewDelegate: UserInfoViewDelegate {
    func cameraButtonPressed()
    func usernameTextFieldEditingChanged()
    func confirmButtonPressed()
}

class SignUpView: UserInfoView {

    let OK = NSLocalizedString("OK", comment: "confirm button title")
    let CREATING_ACCOUNT = NSLocalizedString("CREATING_ACCOUNT", comment: "creating account label text")
    
    lazy var confirmButton: UIButton! = {
        let button = UIButton()
        button.addTarget(self, action: "confirmButtonPressed", forControlEvents: .TouchUpInside)
        button.setTitle(self.OK, forState: .Normal)
        button.backgroundColor = UIColor.appDarkGrayColor()
        button.layer.cornerRadius = 5
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        return button
        }()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    var delegate: SignUpViewDelegate?
    
    override func setup() {
        super.setup()
        frameView.addSubview(confirmButton)
        usernameTextField.delegate = self
        
        loadingLabel.text = CREATING_ACCOUNT
        
        let confirmButtonCenterXConstraint = NSLayoutConstraint(item: confirmButton, attribute: .CenterX, relatedBy: .Equal, toItem: frameView, attribute: .CenterX, multiplier: 1, constant: 0)
        let confirmButtonCenterYConstraint = NSLayoutConstraint(item: confirmButton, attribute: .Top, relatedBy: .Equal, toItem: frameView, attribute: .CenterY, multiplier: 1.5, constant: 0)
        let confirmButtonWidthConstraint = NSLayoutConstraint(item: confirmButton, attribute: .Width, relatedBy: .Equal, toItem: frameView, attribute: .Width, multiplier: 0.5, constant: 0)
        
        frameView.addConstraints([confirmButtonCenterXConstraint, confirmButtonCenterYConstraint, confirmButtonWidthConstraint])
    }
    
    override func updateLayout() {
        cameraButton.layer.cornerRadius = cameraButton.frame.size.width / 2.0
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        let bundle = NSBundle(forClass: self.dynamicType)
        let image = UIImage(named: "camera", inBundle: bundle, compatibleWithTraitCollection: self.traitCollection)
        cameraButtonImage = image
    }
    
    override func cameraButtonPressed() {
        endEditing(true)
        delegate?.cameraButtonPressed()
    }
    
    func confirmButtonPressed() {
        endEditing(true)
        delegate?.confirmButtonPressed()
    }
    
    override func closeButtonPressed() {
        endEditing(true)
        delegate?.closeButtonPressed()
    }
    
    override func usernameTextFieldEditingChanged() {
        delegate?.usernameTextFieldEditingChanged()
    }
}

extension SignUpView: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}