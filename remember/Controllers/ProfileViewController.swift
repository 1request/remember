//
//  ProfileViewController.swift
//  remember
//
//  Created by Joseph Cheung on 22/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol ProfileViewControllerDelegate {
    func closeButtonPressed()
    func feedbackButtonClicked()
}

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileView: ProfileView!
    
    var delegate: ProfileViewControllerDelegate?
    
    var userImage: UIImage? = UIImage.loadPNGImageWithName("user") {
        didSet {
            profileView.cameraButtonImage = userImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let image = userImage {
            profileView.cameraButtonImage = userImage
        }
    }
}

extension ProfileViewController: ProfileViewDelegate {
    func closeButtonPressed() {
        delegate?.closeButtonPressed()
    }
    
    func usernameTextFieldEditingChanged() {
        
    }
    
    func feedbackButtonClicked() {
        delegate?.feedbackButtonClicked()
        delegate?.closeButtonPressed()
    }
    
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
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        if let i = image {
            userImage = i
            
            User.updateProfilePicture(i, callback: nil)
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
