//
//  SignUpViewController.swift
//  remember
//
//  Created by Joseph Cheung on 4/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import MobileCoreServices

@objc protocol SignUpViewControllerDelegate {
    func cancelButtonClicked()
    func didCreateUser()
}

class SignUpViewController: UIViewController {

    @IBOutlet weak var signUpView: SignUpView!
    
    weak var delegate: SignUpViewControllerDelegate?
    
    @IBOutlet weak var creatingAccountLabel: UILabel!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var userImage: UIImage? = nil {
        didSet {
            checkUserData()
            signUpView.cameraButtonImage = userImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpView.delegate = self
        signUpView.confirmButton.enabled = false
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        delegate?.cancelButtonClicked()
        view.endEditing(true)
    }
    
    @IBAction func usernameTextFieldEditingChanged(sender: UITextField) {
        checkUserData()
    }
    
    @IBAction func cameraButtonPressed(sender: UIButton) {
        view.endEditing(true)
    }
    
    func checkUserData() {
        if signUpView.usernameTextField.text != "" && userImage != nil {
            signUpView.confirmButton.enabled = true
            signUpView.confirmButton.backgroundColor = UIColor.appGreenTextColor()
        } else {
            signUpView.confirmButton.enabled = false
            signUpView.confirmButton.backgroundColor = UIColor.appDarkGrayColor()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        userImage = image
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SignUpViewController: SignUpViewDelegate {
    func cameraButtonPressed() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage]
        imagePickerController.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func closeButtonPressed() {
        delegate?.cancelButtonClicked()
    }
    
    func usernameTextFieldEditingChanged() {
        checkUserData()
    }
    
    func confirmButtonPressed() {
        signUpView.showCreatingAccount()
        
        if let image = userImage {
            let user = User(nickname: signUpView.usernameTextField.text, image: image)
            Mixpanel.sharedInstance().people.set(["name": signUpView.usernameTextField.text])
            user.createAccount() { [weak self] in
                if let weakself = self {
                    dispatch_async(dispatch_get_main_queue(), { [weak self]() -> Void in
                        if let wSelf = self {
                            wSelf.delegate?.didCreateUser()
                        }
                    })
                }
            }
        }
    }
}