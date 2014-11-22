//
//  EditLocationViewController.swift
//  remember
//
//  Created by Joseph Cheung on 5/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreData

class EditLocationViewController: UIViewController {

    @IBOutlet weak var editLocationNameTextField: UITextField!
    
    weak var managedObjectContext: NSManagedObjectContext?
    var location:Location? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editLocationNameTextField.text = location?.name
    }
    
    @IBAction func saveButtonClicked(sender: UIBarButtonItem) {
        location?.name = editLocationNameTextField.text
        var error: NSError? = nil
        if !managedObjectContext!.save(&error) {
            println("Cannot update location: \(error)")
        }
        navigationController?.popViewControllerAnimated(true)
    }
}
