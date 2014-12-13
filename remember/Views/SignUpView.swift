//
//  SignUpView.swift
//  remember
//
//  Created by Joseph Cheung on 13/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

protocol SignUpViewDelegate: PopUpViewDelegate {
    func cameraButtonPressed()
    func usernameTextFieldEditingChanged()
    func confirmButtonPressed()
}


class SignUpView: PopUpView {
    let NAME = NSLocalizedString("NAME", comment: "username text field placeholder")
    let OK = NSLocalizedString("OK", comment: "confirm button title")
    let CREATING_ACCOUNT = NSLocalizedString("CREATING_ACCOUNT", comment: "creating account label text")
    
    lazy var cameraButton: UIButton! = {
        let button = UIButton()
        button.addTarget(self, action: "cameraButtonPressed", forControlEvents: .TouchUpInside)
        button.setImage(self.cameraButtonImage, forState: .Normal)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.clipsToBounds = true
        return button
        }()
    
    lazy var usernameTextField: UITextField! = {
        let textField = UITextField()
        textField.setTranslatesAutoresizingMaskIntoConstraints(false)
        textField.addTarget(self, action: "usernameTextFieldEditingChanged", forControlEvents: .EditingChanged)
        textField.borderStyle = .RoundedRect
        textField.backgroundColor = UIColor.appDarkGrayColor()
        textField.placeholder = self.NAME
        textField.delegate = self
        return textField
        }()
    
    lazy var confirmButton: UIButton! = {
        let button = UIButton()
        button.addTarget(self, action: "confirmButtonPressed", forControlEvents: .TouchUpInside)
        button.setTitle(self.OK, forState: .Normal)
        button.backgroundColor = UIColor.appDarkGrayColor()
        button.layer.cornerRadius = 5
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        return button
        }()
    
    lazy var activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.hidesWhenStopped = true
        return view
        }()
    
    lazy var creatingAccountLabel: UILabel = {
        let label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.text = self.CREATING_ACCOUNT
        label.hidden = true
        return label
        }()
    
    var cameraButtonImage: UIImage? = UIImage(named: "camera") {
        didSet {
            cameraButton.setImage(cameraButtonImage, forState: .Normal)
            updateLayout()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    var delegate: SignUpViewDelegate?
    
    override func setup() {
        super.setup()
        frameView.addSubview(cameraButton)
        frameView.addSubview(usernameTextField)
        frameView.addSubview(confirmButton)
        
        overlayView.addSubview(activityView)
        overlayView.addSubview(creatingAccountLabel)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(tapGestureRecognizer)
        
        let cameraButtonCenterXConstraint = NSLayoutConstraint(item: cameraButton, attribute: .CenterX, relatedBy: .Equal, toItem: frameView, attribute: .CenterX, multiplier: 1, constant: 0)
        let cameraButtonCenterYConstraint = NSLayoutConstraint(item: cameraButton, attribute: .CenterY, relatedBy: .Equal, toItem: frameView, attribute: .CenterY, multiplier: 0.5, constant: 0)
        let cameraButtonWidthConstraint = NSLayoutConstraint(item: cameraButton, attribute: .Width, relatedBy: .Equal, toItem: frameView, attribute: .Width, multiplier: 0.35, constant: 0)
        let cameraButtonHeightConstraint = NSLayoutConstraint(item: cameraButton, attribute: .Height, relatedBy: .Equal, toItem: cameraButton, attribute: .Width, multiplier: 1, constant: 0)
        cameraButton.addConstraint(cameraButtonHeightConstraint)
        
        frameView.addConstraints([cameraButtonCenterXConstraint, cameraButtonCenterYConstraint, cameraButtonWidthConstraint])
        
        let usernameTextFieldCenterXConstraint = NSLayoutConstraint(item: usernameTextField, attribute: .CenterX, relatedBy: .Equal, toItem: frameView, attribute: .CenterX, multiplier: 1, constant: 0)
        let usernameTextFieldCenterYConstraint = NSLayoutConstraint(item: usernameTextField, attribute: .CenterY, relatedBy: .Equal, toItem: frameView, attribute: .CenterY, multiplier: 1.1, constant: 0)
        let usernameTextFieldWidthConstraint = NSLayoutConstraint(item: usernameTextField, attribute: .Width, relatedBy: .Equal, toItem: frameView, attribute: .Width, multiplier: 0.8, constant: 0)
        
        frameView.addConstraints([usernameTextFieldCenterXConstraint, usernameTextFieldCenterYConstraint, usernameTextFieldWidthConstraint])
        
        let confirmButtonCenterXConstraint = NSLayoutConstraint(item: confirmButton, attribute: .CenterX, relatedBy: .Equal, toItem: frameView, attribute: .CenterX, multiplier: 1, constant: 0)
        let confirmButtonCenterYConstraint = NSLayoutConstraint(item: confirmButton, attribute: .Top, relatedBy: .Equal, toItem: frameView, attribute: .CenterY, multiplier: 1.5, constant: 0)
        let confirmButtonWidthConstraint = NSLayoutConstraint(item: confirmButton, attribute: .Width, relatedBy: .Equal, toItem: frameView, attribute: .Width, multiplier: 0.5, constant: 0)
        
        frameView.addConstraints([confirmButtonCenterXConstraint, confirmButtonCenterYConstraint, confirmButtonWidthConstraint])
        
        let creatingAccountLabelHorizontalConstraint = NSLayoutConstraint(item: creatingAccountLabel, attribute: .CenterX, relatedBy: .Equal, toItem: overlayView, attribute: .CenterX, multiplier: 1, constant: 0)
        let creatingAccountLabelVerticalConstraint = NSLayoutConstraint(item: creatingAccountLabel, attribute: .CenterY, relatedBy: .Equal, toItem: overlayView, attribute: .CenterY, multiplier: 1, constant: 0)
        let activityViewHorizontalConstraint = NSLayoutConstraint(item: activityView, attribute: .Trailing, relatedBy: .Equal, toItem: creatingAccountLabel, attribute: .Leading, multiplier: 1, constant: -8)
        let activityViewVerticalConstraint = NSLayoutConstraint(item: activityView, attribute: .CenterY, relatedBy: .Equal, toItem: overlayView, attribute: .CenterY, multiplier: 1, constant: 0)
        
        overlayView.addConstraints([creatingAccountLabelHorizontalConstraint, creatingAccountLabelVerticalConstraint, activityViewHorizontalConstraint, activityViewVerticalConstraint])
    }
    
    func updateLayout() {
        cameraButton.layer.cornerRadius = cameraButton.frame.size.width / 2.0
    }
    
    func showCreatingAccount() {
        frameView.hidden = true
        closeButton.hidden = true
        activityView.startAnimating()
        creatingAccountLabel.hidden = false
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        let bundle = NSBundle(forClass: self.dynamicType)
        let image = UIImage(named: "camera", inBundle: bundle, compatibleWithTraitCollection: self.traitCollection)
        cameraButtonImage = image
    }
    
    func cameraButtonPressed() {
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
    
    func usernameTextFieldEditingChanged() {
        delegate?.usernameTextFieldEditingChanged()
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        endEditing(true)
    }
}

extension SignUpView: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}