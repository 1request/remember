//
//  HomeViewController.swift
//  remember
//
//  Created by Kaeli Lo on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, MessagesTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recordButton: UIButton!

    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var managedObjectContext = NSManagedObjectContext()
    var fetchedResultController: NSFetchedResultsController!
    
    var objectsInTable: NSMutableArray = []
    var _selectedLocationObjectID: NSManagedObjectID? = nil
    
    var editingCellRowNumber:NSInteger = 0
    
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
        
        recordButton.addTarget(self, action: Selector("finishRecordingAudio"), forControlEvents: UIControlEvents.TouchUpInside)
      
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
        var object: AnyObject = objectsInTable.objectAtIndex(indexPath.row)
        if object is Location {
            let location:Location = objectsInTable.objectAtIndex(indexPath.row) as Location
            
            var cell = tableView.dequeueReusableCellWithIdentifier("locationsCell", forIndexPath: indexPath) as LocationsTableViewCell
            cell.locationNameLabel.text = location.name
            if location.objectID == selectedLocationObjectID() {
                cell.checkRadioButton()
            }
            
            return cell
        } else {
            let message:Message = objectsInTable.objectAtIndex(indexPath.row) as Message
            
            println("Creating cell for " + message.name)
            var cell = tableView.dequeueReusableCellWithIdentifier("messagesCell", forIndexPath: indexPath) as MessagesTableViewCell
            cell.delegate = self
            cell.messageLabel.text = message.name
            if message.isRead.boolValue {
                cell.markAsRead()
            } else {
                cell.markAsUnread()
            }
            
            if indexPath.row == self.editingCellRowNumber {
                cell.openCell()
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
                
                var message: Message = objectsInTable.objectAtIndex(indexPath.row) as Message
                message.isRead = true
                message.updatedAt = NSDate()
                appDelegate.saveContext()
            }
        }
    }
    
    func closeEditingCell() {
        var indexPath = NSIndexPath(forRow: editingCellRowNumber, inSection: 0)
        var previousEditingCell: MessagesTableViewCell? = tableView.cellForRowAtIndexPath(indexPath) as? MessagesTableViewCell
        
        if previousEditingCell != nil {
//            previousEditingCell?.closeCell(true)
        }
        
        editingCellRowNumber = 0
    }
    
    //MARK: MessagesTableViewCellDelegate
    
    func deleteButtonClicked(cell: UITableViewCell) {
        var indexPath: NSIndexPath = tableView.indexPathForCell(cell)!
        var message: Message = objectsInTable.objectAtIndex(indexPath.row) as Message
        managedObjectContext.deleteObject(message)
        editingCellRowNumber = 0
        
        var error: NSError? = nil
        if managedObjectContext.save(&error) {
            NSLog("Unable to save managed object content.")
        }
    }
    
    func cellWillOpen(cell: UITableViewCell) {
        if editingCellRowNumber != 0 {
            closeEditingCell()
        }
    }
    
    func cellDidOpen(cell: UITableViewCell) {
        var indexPath: NSIndexPath = tableView.indexPathForCell(cell)!
        editingCellRowNumber = indexPath.row
    }
    
    func cellDidClose(cell: UITableViewCell) {
        editingCellRowNumber = 0
    }
    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let devicesVC = segue.destinationViewController as? DevicesTableViewController {
            devicesVC.managedObjectContext = self.managedObjectContext
        }
    }

    // NSFetchedResultControllerDelegate
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        setObjectsInTable()
        tableView.reloadData()
    }
    
    // MARK: Actions
    func finishRecordingAudio() {
        let entityDescription = NSEntityDescription.entityForName("Message", inManagedObjectContext: managedObjectContext)
        let message = Message(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        
        let createTime = NSDate()
        
        message.location = managedObjectContext.objectWithID(selectedLocationObjectID()) as Location
        message.location.messageCount = message.location.messageCount + 1
        message.name = "Record \(message.location.messageCount)"
        message.isRead = false
        message.createdAt = createTime
        message.updatedAt = createTime
        
        appDelegate.saveContext()
    }
    
    // Data
    func getFetchedResultController() -> NSFetchedResultsController {
        let fetchRequest = NSFetchRequest(entityName: "Location")
        fetchRequest.relationshipKeyPathsForPrefetching = ["messages"]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]

        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
    }
    
    func setManagedObjectContext() {
        fetchedResultController = getFetchedResultController()
        fetchedResultController.delegate = self
        fetchedResultController.performFetch(nil)

        setObjectsInTable()
    }
    
    func setObjectsInTable() {
        // clear table
        objectsInTable = []

        var fetchedLocations = fetchedResultController.fetchedObjects
        for var i = 0; i < fetchedLocations?.count; i++ {
            var location: Location = fetchedLocations?[i] as Location
            objectsInTable.addObject(location)
            
            var sortByIsRead = NSSortDescriptor(key: "isRead", ascending: true)
            var sortByCreatedAt = NSSortDescriptor(key: "createdAt", ascending: false)
            var sortedMessages = location.messages.sortedArrayUsingDescriptors([sortByIsRead, sortByCreatedAt])
            objectsInTable.addObjectsFromArray(sortedMessages)
        }
    }
    
    // Testing
    func addTestingData() {
        var createTime = NSDate()
        
        let locationEntityDescription = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
        let location = Location(entity: locationEntityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        location.name = "Testing Area"
        location.createdAt = createTime
        location.updatedAt = createTime

        appDelegate.saveContext()
    }

}
