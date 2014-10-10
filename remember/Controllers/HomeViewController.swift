//
//  HomeViewController.swift
//  remember
//
//  Created by Kaeli Lo on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recordButton: UIButton!

    var appDelegate: AppDelegate!
    var manageObjectContext: NSManagedObjectContext!
    var fetchedResultController: NSFetchedResultsController!
    
    var objectsInTable: NSMutableArray = []
    var _selectedLocationObjectID: NSManagedObjectID? = nil
    
    func selectedLocationObjectID() -> NSManagedObjectID {
        if _selectedLocationObjectID == nil {
            var location: Location? = objectsInTable.firstObject as? Location
            if location != nil {
                _selectedLocationObjectID = location?.objectID
            }
        }
        
        return _selectedLocationObjectID!
    }
    
    // UIView Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add remember logo to navigation bar
        let logo = UIImage(named: "remember-logo")
        let logoImageView = UIImageView(image: logo)
        self.navigationItem.titleView = logoImageView
      
        setManagedObjectContext()

        if fetchedResultController.fetchedObjects?.count == 0 {
            addTestingData()
            
//            tableView.hidden = true
//            recordButton.hidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectsInTable.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let location:Location = objectsInTable.objectAtIndex(indexPath.row) as Location
            
            var cell = tableView.dequeueReusableCellWithIdentifier("locationsCell", forIndexPath: indexPath) as LocationsTableViewCell
            cell.locationNameLabel.text = location.name
            if location.objectID == selectedLocationObjectID() {
                cell.checkRadioButton()
            }
            
            return cell
        } else {
            let message:Message = objectsInTable.objectAtIndex(indexPath.row) as Message
            
            var cell = tableView.dequeueReusableCellWithIdentifier("messagesCell", forIndexPath: indexPath) as MessagesTableViewCell
            cell.messageLabel.text = message.name
            if message.isRead.boolValue {
                cell.markAsRead()
            }
            
            return cell
        }
    }
    
    // UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is LocationsTableViewCell {
            var locationCell: LocationsTableViewCell = cell as LocationsTableViewCell
            if locationCell.isChecked() {
                locationCell.uncheckedRadioButton()
            } else {
                locationCell.checkRadioButton()
            }
        } else {
            var messageCell: MessagesTableViewCell = cell as MessagesTableViewCell
            if messageCell.playing {
                messageCell.finishPlaying()
            } else {
                messageCell.startPlaying()
            }
        }
    }
    
    // NSFetchedResultControllerDelegate
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        setObjectsInTable()
        tableView.reloadData()
    }
    
    // Data
    func getFetchedResultController() -> NSFetchedResultsController {
        let fetchRequest = NSFetchRequest(entityName: "Location")
        fetchRequest.relationshipKeyPathsForPrefetching = ["messages"]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]

        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: manageObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
    }
    
    func setManagedObjectContext() {
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        manageObjectContext = appDelegate.managedObjectContext!

        fetchedResultController = getFetchedResultController()
        fetchedResultController.delegate = self
        fetchedResultController.performFetch(nil)

        setObjectsInTable()
    }
    
    func setObjectsInTable() {
        var fetchedLocations = fetchedResultController.fetchedObjects
        for var i = 0; i < fetchedLocations?.count; i++ {
            var location: Location = fetchedLocations?[i] as Location
            objectsInTable.addObject(location)
            objectsInTable.addObjectsFromArray(location.messages.allObjects)
        }
    }
    
    // Testing
    func addTestingData() {
        let locationEntityDescription = NSEntityDescription.entityForName("Location", inManagedObjectContext: manageObjectContext)
        let location = Location(entity: locationEntityDescription!, insertIntoManagedObjectContext: manageObjectContext)
        location.name = "Testing Area"

        let messageEntityDescription = NSEntityDescription.entityForName("Message", inManagedObjectContext: manageObjectContext)
        let message = Message(entity: messageEntityDescription!, insertIntoManagedObjectContext: manageObjectContext)
        message.location = location
        message.location.messageCount = message.location.messageCount + 1
        message.name = "Record \(message.location.messageCount)"
        
        appDelegate.saveContext()
    }
}
