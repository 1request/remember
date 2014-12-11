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

class SignUpViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var formView: UIView!

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var formBackgroundView: UIView!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    weak var delegate: SignUpViewControllerDelegate?
    
    var group: Group?
    
    @IBOutlet weak var creatingAccountLabel: UILabel!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var userImage: UIImage? = nil {
        didSet {
            checkUserData()
        }
    }
    
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
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
        userImageView.layer.masksToBounds = true
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
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.mediaTypes = [kUTTypeImage]
            imagePickerController.allowsEditing = true
            imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
            presentViewController(imagePickerController, animated: true, completion: nil)
        } else {
            NSLog("No camera")
        }
    }
    
    @IBAction func confirmButtonPressed(sender: UIButton) {
        
        activityView.hidden = false
        creatingAccountLabel.hidden = false
        activityView.startAnimating()
        cameraButton.hidden = true
        userImageView.hidden = true
        usernameTextField.hidden = true
        confirmButton.hidden = true
        
        if let image = userImageView.image {
            let user = User(nickname: usernameTextField.text, image: userImageView.image!)
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
        
        view.endEditing(true)
    }
    
    func checkUserData() {
        if usernameTextField.text != "" && userImage != nil {
            confirmButton.enabled = true
        } else {
            confirmButton.enabled = false
        }
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
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
        
        userImageView.image = userImage
        userImageView.hidden = false
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
