//
//  ProfileView.swift
//  remember
//
//  Created by Joseph Cheung on 22/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

protocol ProfileViewDelegate: UserInfoViewDelegate {
    func feedbackButtonClicked()
}

@IBDesignable
class ProfileView: UserInfoView {
    let FEEDBACK = NSLocalizedString("FEEDBACK", comment: "feedback button title")
    
    lazy var feedbackButton: UIButton = {
        let button = UIButton()
        button.setTitle(self.FEEDBACK, forState: .Normal)
        button.setTitleColor(UIColor.appGreenTextColor(), forState: .Normal)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "feedbackButtonClicked", forControlEvents: .TouchUpInside)
        return button
        }()
    
    var delegate: ProfileViewDelegate?
    
    override func setup() {
        super.setup()
        frameView.addSubview(feedbackButton)
        
        let viewsDict = ["feedbackButton": feedbackButton]
        
        let feedbackButtonBottomConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[feedbackButton]-|", options: .DirectionLeadingToTrailing, metrics: nil, views: viewsDict)
        
        let feedbackButtonTrailingConstraint = NSLayoutConstraint(item: feedbackButton, attribute: .Trailing, relatedBy: .Equal, toItem: usernameTextField, attribute: .Trailing, multiplier: 1.0, constant: 0)
        
        frameView.addConstraints(feedbackButtonBottomConstraints)
        frameView.addConstraint(feedbackButtonTrailingConstraint)
    }
    
    func feedbackButtonClicked() {
        endEditing(true)
        delegate?.feedbackButtonClicked()
    }
    
    override func cameraButtonPressed() {
        endEditing(true)
        delegate?.cameraButtonPressed()
    }
    
    override func closeButtonPressed() {
        endEditing(true)
        delegate?.closeButtonPressed()
    }
    
    override func usernameTextFieldEditingChanged() {
        delegate?.usernameTextFieldEditingChanged()
    }
}
