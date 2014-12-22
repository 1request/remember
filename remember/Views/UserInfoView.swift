//
//  UserInfoView.swift
//  remember
//
//  Created by Joseph Cheung on 22/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

protocol UserInfoViewDelegate: PopUpViewDelegate {
    func cameraButtonPressed()
    func usernameTextFieldEditingChanged()
}

class UserInfoView: PopUpView, UITextFieldDelegate {
    let NAME = NSLocalizedString("NAME", comment: "username text field placeholder")
    
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
        return textField
        }()
    
    lazy var activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.hidesWhenStopped = true
        return view
        }()
    
    lazy var loadingLabel: UILabel = {
        let label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.hidden = true
        return label
        }()
    
    var userInfoDelegate: UserInfoViewDelegate?
    
    override func setup() {
        super.setup()
        frameView.addSubview(cameraButton)
        frameView.addSubview(usernameTextField)
        
        overlayView.addSubview(activityView)
        overlayView.addSubview(loadingLabel)
        
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
        
        let creatingAccountLabelHorizontalConstraint = NSLayoutConstraint(item: loadingLabel, attribute: .CenterX, relatedBy: .Equal, toItem: overlayView, attribute: .CenterX, multiplier: 1, constant: 0)
        let creatingAccountLabelVerticalConstraint = NSLayoutConstraint(item: loadingLabel, attribute: .CenterY, relatedBy: .Equal, toItem: overlayView, attribute: .CenterY, multiplier: 1, constant: 0)
        let activityViewHorizontalConstraint = NSLayoutConstraint(item: activityView, attribute: .Trailing, relatedBy: .Equal, toItem: loadingLabel, attribute: .Leading, multiplier: 1, constant: -8)
        let activityViewVerticalConstraint = NSLayoutConstraint(item: activityView, attribute: .CenterY, relatedBy: .Equal, toItem: overlayView, attribute: .CenterY, multiplier: 1, constant: 0)
        
        overlayView.addConstraints([creatingAccountLabelHorizontalConstraint, creatingAccountLabelVerticalConstraint, activityViewHorizontalConstraint, activityViewVerticalConstraint])
    }
    
    func updateLayout() {
        cameraButton.layer.cornerRadius = frameView.frame.size.width * 0.35 / 2.0
    }
    
    func showCreatingAccount() {
        frameView.hidden = true
        closeButton.hidden = true
        activityView.startAnimating()
        loadingLabel.hidden = false
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        let bundle = NSBundle(forClass: self.dynamicType)
        let image = UIImage(named: "camera", inBundle: bundle, compatibleWithTraitCollection: self.traitCollection)
        cameraButtonImage = image
    }
    
    func cameraButtonPressed() {
        userInfoDelegate?.cameraButtonPressed()
    }
    
    override func closeButtonPressed() {
        userInfoDelegate?.closeButtonPressed()
    }
    
    func usernameTextFieldEditingChanged() {
        userInfoDelegate?.usernameTextFieldEditingChanged()
    }
}
