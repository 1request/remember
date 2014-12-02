//
//  HomeViewController.swift
//  remember
//
//  Created by Kaeli Lo on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import CoreLocation

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    //MARK: - Constants

    var kApplicationPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last! as String
    var hudView = HUD()

    var recorderViewController: RecorderViewController? = nil

    //MARK: - Variables

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pressHereImageView: UIImageView!
    var alertView: UIAlertView? = nil

    var editingObjectID: NSManagedObjectID? = nil
    var openedCellDirection: SwipeableTableViewCell.Direction?

    weak var managedObjectContext: NSManagedObjectContext!
    var fetchedResultController: NSFetchedResultsController!

    var objectsInTable: NSMutableArray = []
    var selectedLocationObjectID: NSManagedObjectID?

    var activePlayerIndexPath: NSIndexPath?

    var player:AVAudioPlayer?

    //MARK: - UIView Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add remember logo to navigation bar
        let logo = UIImage(named: "remember-logo")
        let logoImageView = UIImageView(image: logo)
        navigationItem.titleView = logoImageView
        tableView.removeFooterBorder()

        setManagedObjectContext()

        tableView.registerClass(MessagesTableViewCell.self, forCellReuseIdentifier: "messageCell")
        tableView.registerClass(LocationsTableViewCell.self, forCellReuseIdentifier: "locationCell")
        tableView.delegate = self

        updateViewToBePresented()

        // detect tap gesture
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "tapView:")
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        monitorEnterLocationNotification()
        monitorAudioRouteChange()
        setSelectedLocationObjectID()
    }


    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        unmonitorEnterLocationNotification()
        unmonitorAudioRouteChange()
        resetEditMode()
    }

    //MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectsInTable.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = setCellAtIndexPath(indexPath)
        if let swipeableCell = cell as? SwipeableTableViewCell {
            swipeableCell.delegate = self
            swipeableCell.updateConstraints()

            let index = indexOfEditingObject()

            if indexPath.row == index {
                swipeableCell.openCell(animated: false, direction: openedCellDirection!)
            }
        }
        return cell
    }

    func indexOfEditingObject() -> Int? {
        if let objectID = editingObjectID {
            let objectIDs = map(objectsInTable) { $0.objectID } as NSArray
            return objectIDs.indexOfObject(objectID)
        } else {
            return nil
        }
    }

    func setCellAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let object: AnyObject = objectsInTable.objectAtIndex(indexPath.row)
        if object is Location {
            let location = object as Location
            let cell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath) as LocationsTableViewCell
            cell.locationNameLabel.text = location.name
            if location.objectID == selectedLocationObjectID {
                cell.checkRadioButton()
            } else {
                cell.uncheckedRadioButton()
            }
            return cell
        } else {
            let message = object as Message
            let cell = tableView.dequeueReusableCellWithIdentifier("messageCell", forIndexPath: indexPath) as MessagesTableViewCell
            cell.messageLabel.text = message.name
            if message.isRead.boolValue {
                cell.markAsRead()
            } else {
                cell.markAsUnread()
            }
            if message.objectID == editingObjectID {
                cell.setPlayerStatus(cell.status)
                cell.active = false
            } else {
                cell.setPlayerStatus(cell.status)
                cell.active = true
            }
            return cell
        }
    }

    func reloadSection() {
        let range = NSMakeRange(0, 1)
        let section = NSIndexSet(indexesInRange: range)
        tableView.reloadSections(section, withRowAnimation: UITableViewRowAnimation.Automatic)
    }

    func selectedLocationIndexPath() -> NSIndexPath {
        let location = managedObjectContext!.objectWithID(selectedLocationObjectID!) as Location
        let index = objectsInTable.indexOfObject(location)
        return NSIndexPath(forRow: index, inSection: 0)
    }

    //MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if editingObjectID != nil {
            // has editing cell, close cell
            resetEditMode()
        }

        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let locationCell = cell as? LocationsTableViewCell {
            let location = objectsInTable[indexPath.row] as Location
            var rowsToReload = [selectedLocationIndexPath()]
            if selectedLocationObjectID != location.objectID {
                selectedLocationObjectID = location.objectID
                rowsToReload.append(selectedLocationIndexPath())
            }
            tableView.reloadRowsAtIndexPaths(rowsToReload, withRowAnimation: .Automatic)
        } else {
            let messageCell = cell as MessagesTableViewCell
            if messageCell.status == MessagesTableViewCell.PlayerStatus.Playing {
                stopPlayingAudio()
            } else {
                // stop any existing playing record
                stopPlayingAudio()
                messageCell.startPlaying()
                playAudioAtIndexPath(indexPath)
                activePlayerIndexPath = indexPath
                let message = objectsInTable.objectAtIndex(indexPath.row) as Message
                message.isRead = true
                message.updatedAt = NSDate()
                managedObjectContext.save(nil)
                monitorLocation(message.location)
            }
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    func resetEditMode () {
        editingObjectID = nil
        openedCellDirection = nil
        recorderViewController?.recordButton.enabled = true
    }

    func closeEditingCell() {
        if let index = indexOfEditingObject() {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            if let previousEditingCell = cell as? SwipeableTableViewCell {
                previousEditingCell.closeCell(animated: true, direction: openedCellDirection!)
            }
            if let messageCell = cell as? MessagesTableViewCell {
                messageCell.active = true
            }
        }
    }

    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let locationsVC = segue.destinationViewController as? LocationsViewController {
            locationsVC.managedObjectContext = managedObjectContext
        }
        if let editLocationVC = segue.destinationViewController as? EditLocationViewController {
            if let location = sender as? Location {
                editLocationVC.location = location
                editLocationVC.managedObjectContext = managedObjectContext
            }
        }
        if let recorderVC = segue.destinationViewController as? RecorderViewController {
            recorderViewController = recorderVC
            recorderViewController?.delegate = self
        }
    }

    //MARK: - NSFetchedResultControllerDelegate

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if tableView.hidden {
            tableView.hidden = false
            recorderViewController?.recordButton.hidden = false
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        setObjectsInTable()
        setSelectedLocationObjectID()
        reloadSection()
        updateViewToBePresented()
    }
    //MARK: - Layout

    func updateViewToBePresented() {
        if fetchedResultController.fetchedObjects?.count == 0 {
            tableView.hidden = true
            recorderViewController?.recordButton.hidden = true
            pressHereImageView.hidden = false
        }
        else {
            pressHereImageView.hidden = true
        }
    }

    //MARK: - Core Data
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
            var sortByCreatedAt = NSSortDescriptor(key: "createdAt", ascending: true)
            var sortedMessages = location.messages.sortedArrayUsingDescriptors([sortByIsRead, sortByCreatedAt])

            objectsInTable.addObjectsFromArray(sortedMessages)
        }

        setSelectedLocationObjectID()
    }

    func setSelectedLocationObjectID() {

        if let locationIdentifier = NSUserDefaults.standardUserDefaults().valueForKey("location") as? String {
            let predicate = NSPredicate(format: "identifier == %@", locationIdentifier)
            let request = NSFetchRequest(entityName: "Location")
            request.predicate = predicate
            if let locations = managedObjectContext.executeFetchRequest(request, error: nil) {
                let location = locations.first as Location
                selectedLocationObjectID = location.objectID
                NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "location")
                return
            }
        }

        if let id = selectedLocationObjectID {
            if let location = managedObjectContext.existingObjectWithID(id, error: nil) {
                if !location.deleted {
                    return
                }
            }
        }

        if objectsInTable.count == 0 {
            selectedLocationObjectID = nil
            return
        }

        if let location = objectsInTable[0] as? Location {
            selectedLocationObjectID = location.objectID
        }
    }

    //MARK: - Play Audio

    func playAudioAtIndexPath (indexPath: NSIndexPath) {
        Mixpanel.sharedInstance().track("startPlaying")

        let message = objectsInTable.objectAtIndex(indexPath.row) as Message
        let filePath = kApplicationPath + "/" + message.createdAt.timeIntervalSince1970.format(".0") + ".m4a"
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            var error: NSError?
            player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: filePath), error: &error)
            if let e = error {
                println("error playing audio at indexpath:\(indexPath), error: \(e.localizedDescription)")
            }
            else {
                player?.delegate = self
                player?.play()
            }
        }
    }

    func stopPlayingAudio () {
        if let indexPath = activePlayerIndexPath {
            if let messageCell = tableView.cellForRowAtIndexPath(indexPath) as? MessagesTableViewCell {
                messageCell.finishPlaying()
            }
        }

        player?.stop()
    }

    //MARK: - Monitor Location

    func monitorLocation(location: Location) {
        let predicate = NSPredicate(format: "isRead == 0")
        let unreadMessages = location.messages.filteredSetUsingPredicate(predicate!)
        let locationManager = LocationManager.sharedInstance
        if location.uuid != "" {
            let beaconRegion = location.beaconRegion()
            if unreadMessages.count == 0 {
                locationManager.stopRangingBeaconRegions([beaconRegion])
                locationManager.stopMonitoringRegions([beaconRegion])
            }
            else {
                locationManager.startRangingBeaconRegions([beaconRegion])
                locationManager.startMonitoringRegions([beaconRegion])
            }
        } else {
            let circularRegion = location.circularRegion()
            if unreadMessages.count == 0 {
                locationManager.stopMonitoringRegions([circularRegion])
            }
            else {
                locationManager.startMonitoringRegions([circularRegion])
            }
        }
    }
}

//MARK: - AVAudioPlayerDelegate

extension HomeViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!,
        successfully flag: Bool) {
            stopPlayingAudio()
            if let indexPath = activePlayerIndexPath {
                if let message = objectsInTable[indexPath.row] as? Message {
                    let location = message.location
                    activePlayerIndexPath = nil
                }
            }
            setObjectsInTable()
            reloadSection()
    }
}

//MARK: - UIGestureRecognizerDelegate

extension HomeViewController : UIGestureRecognizerDelegate {
    func tapView (recognizer: UITapGestureRecognizer) {
        closeEditingCell()
        resetEditMode()
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if editingObjectID != nil {
            return true
        }
        return false
    }
}

//MARK: - SwipeableTableViewCellDelegate
extension HomeViewController: SwipeableTableViewCellDelegate {
    func swipeableCellDidOpen(cell: SwipeableTableViewCell, direction: Int) {
        openedCellDirection = SwipeableTableViewCell.Direction(rawValue: direction)
        closeEditingCell()

        if let indexPath = tableView.indexPathForCell(cell) {
            editingObjectID = objectsInTable[indexPath.row].objectID
        }

        if let messageCell = cell as? MessagesTableViewCell {
            messageCell.active = false
        }
    }

    func swipeableCellDidClose(cell: SwipeableTableViewCell, direction: Int) {
        resetEditMode()

        if let messageCell = cell as? MessagesTableViewCell {
            messageCell.active = true
        }
    }

    func swipeableCell(cell: SwipeableTableViewCell, didSelectButtonAtIndex index: Int, direction: Int) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let object = objectsInTable.objectAtIndex(indexPath.row) as NSManagedObject

            if direction == SwipeableTableViewCell.Direction.right.rawValue {
                if index == 0 {
                    deleteObjectAtIndexPath(indexPath)
                    setObjectsInTable()
                    setSelectedLocationObjectID()
                } else {
                    if let location = object as? Location {
                        performSegueWithIdentifier("editLocation", sender: location)
                    }
                }
            } else {
                if let message = object as? Message {
                    let cell = tableView.cellForRowAtIndexPath(indexPath) as MessagesTableViewCell
                    cell.markAsUnread()

                    message.isRead = false
                    message.updatedAt = NSDate()
                    managedObjectContext.save(nil)

                    closeEditingCell()
                }
            }
        }
        resetEditMode()
        setObjectsInTable()
        reloadSection()
    }

    func deleteObjectAtIndexPath(indexPath: NSIndexPath) {
        let object = objectsInTable.objectAtIndex(indexPath.row) as NSManagedObject
        if let location = object as? Location {
            LocationManager.sharedInstance.stopMonitoringRegions([location.region()])
            if location.uuid != "" {
                LocationManager.sharedInstance.stopRangingBeaconRegions([location.beaconRegion()])
            }
        } else if let message = object as? Message {
            if activePlayerIndexPath == indexPath {
                player?.stop()
                activePlayerIndexPath = nil
            }
        }
        managedObjectContext!.deleteObject(object)
        var error: NSError? = nil
        if !managedObjectContext!.save(&error) {
            println("unable to delete object, error: \(error?.localizedDescription)")
        }
        if objectsInTable.count == 0 {
            selectedLocationObjectID = nil
            return
        }
        if let location = objectsInTable[0] as? Location {
            selectedLocationObjectID = location.objectID
        }
    }
}

// Observe Location Notification
extension HomeViewController: UIAlertViewDelegate {
    func monitorEnterLocationNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "triggerNotification:", name: kAlertLocationNotificationName, object: nil)
    }

    func unmonitorEnterLocationNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kAlertLocationNotificationName, object: nil)
    }

    func triggerNotification(notification: NSNotification) {
        if let dict = notification.userInfo as? [String: AnyObject] {
            let title = dict["title"] as String
            let message = dict["message"] as String
            alertView?.dismissWithClickedButtonIndex(0, animated: false)
            alertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "OK")
            alertView?.show()
            setSelectedLocationObjectID()
            reloadSection()
        }
    }
}

extension HomeViewController {
    func monitorAudioRouteChange() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAudioRoute:", name: AVAudioSessionRouteChangeNotification, object: nil)
    }

    func unmonitorAudioRouteChange() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVAudioSessionRouteChangeNotification, object: nil)
    }

    func updateAudioRoute(notification: NSNotification) {
        if let dict = notification.userInfo as? Dictionary<String, AnyObject> {
            let routeChangeReason = dict[AVAudioSessionRouteChangeReasonKey] as Int
            if routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable {
                stopPlayingAudio()
            }
        }
    }
}

extension HomeViewController: RecorderViewControllerDelegate {

    func recorderWillStartRecording() {
        if editingObjectID != nil {
            closeEditingCell()
            resetEditMode()
        }

        if let player = player {
            if player.playing {
                player.stop()
            }
        }

        hudView = HUD.hudInView(view)
        hudView.text = SLIDE_UP_TO_CANCEL
    }

    func recorderWillFinishRecording() {
        hudView.removeFromSuperview()
    }

    func recorderDidFinishRecording(#valid: Bool) {
        if valid {
            Mixpanel.sharedInstance().track("audioRecorded")

            let location = managedObjectContext!.objectWithID(selectedLocationObjectID!) as Location
            createMessageForLocation(location)
            monitorLocation(location)
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        }
    }

    func recorderWillCancelRecording() {
        hudView.removeFromSuperview()
    }

    func recorderButtonDidDragEnter() {
        hudView.text = SLIDE_UP_TO_CANCEL
        hudView.setNeedsDisplay()
    }

    func recorderButtonDidDragExit() {
        hudView.text = RELEASE_TO_CANCEL
        hudView.setNeedsDisplay()
    }

    func createMessageForLocation (location: Location) {
        let entityDescription = NSEntityDescription.entityForName("Message", inManagedObjectContext: managedObjectContext!)
        let message = Message(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)

        let createTime = NSDate()
        let filePathString = kApplicationPath + "/" + createTime.timeIntervalSince1970.format(".0") + ".m4a"

        let outputFileURL = NSURL(fileURLWithPath: filePathString)

        var error: NSError?
        if let recorder = recorderViewController?.recorder {
            if !NSFileManager.defaultManager().copyItemAtURL(recorder.url, toURL: outputFileURL!, error: &error) {
                println("error copying item to url: \(error?.localizedDescription)")
            }

            message.location = location

            message.location.messageCount = NSNumber(integer: (message.location.messageCount.integerValue + 1))
            message.name = String(format: RECORD_NAME, message.location.messageCount)
            message.isRead = false
            message.createdAt = createTime
            message.updatedAt = createTime

            location.updatedAt = createTime

            if !managedObjectContext!.save(&error) {
                println("error saving audio: \(error?.localizedDescription)")
            }
        }
    }

}
