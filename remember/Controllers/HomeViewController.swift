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
    let APPROVE = NSLocalizedString("APPROVE", comment: "alert action for approving new member")
    let REJECT = NSLocalizedString("REJECT", comment: "alert action for rejecting new member")
    
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
    var selectedGroupObjectID: NSManagedObjectID?

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
        tableView.registerClass(GroupsTableViewCell.self, forCellReuseIdentifier: "groupCell")
        tableView.delegate = self

        updateViewToBePresented()

        // detect tap gesture
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "tapView:")
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillResignActiveNotification, object: nil, queue: nil) { (notification) -> Void in
            self.hudView.removeFromSuperview()
            self.recorderViewController?.recorder.stopRecordingAudio()
            
            if let url = self.recorderViewController?.recorder.url {
                if NSFileManager.defaultManager().fileExistsAtPath(url.path!) {
                    self.handleRecordedAudio()
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkNewMember()
        monitorEnterLocationNotification()
        monitorApproveMemberNotification()
        monitorAudioRouteChange()
        setSelectedGroupObjectID()
        Group.updateAcceptedGroupsInContext(managedObjectContext, nil)
    }


    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        unmonitorEnterLocationNotification()
        unmonitorApproveMemberNotification()
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
        if let group = object as? Group {
            let cell = tableView.dequeueReusableCellWithIdentifier("groupCell", forIndexPath: indexPath) as GroupsTableViewCell
            cell.groupNameLabel.text = group.name
            if group.objectID == selectedGroupObjectID {
                cell.radioButton.checked = true
            } else {
                cell.radioButton.checked = false
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

    func selectedGroupIndexPath() -> NSIndexPath {
        let group = managedObjectContext!.objectWithID(selectedGroupObjectID!) as Group
        let index = objectsInTable.indexOfObject(group)
        return NSIndexPath(forRow: index, inSection: 0)
    }

    //MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if editingObjectID != nil {
            // has editing cell, close cell
            resetEditMode()
        }

        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let groupCell = cell as? GroupsTableViewCell {
            let group = objectsInTable[indexPath.row] as Group
            var rowsToReload = [selectedGroupIndexPath()]
            if selectedGroupObjectID != group.objectID {
                selectedGroupObjectID = group.objectID
                rowsToReload.append(selectedGroupIndexPath())
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
                monitorLocationOfGroup(message.group)
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
        if let editGroupVC = segue.destinationViewController as? EditGroupViewController {
            if let group = sender as? Group {
                editGroupVC.group = group
                editGroupVC.managedObjectContext = managedObjectContext
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
        setSelectedGroupObjectID()
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
        let fetchRequest = NSFetchRequest(entityName: "Group")
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

        var fetchedGroups = fetchedResultController.fetchedObjects as [Group]?
        if let groups = fetchedGroups {
            for (index, group) in enumerate(groups) {
                objectsInTable.addObject(group)
                
                var sortByIsRead = NSSortDescriptor(key: "isRead", ascending: true)
                var sortByCreatedAt = NSSortDescriptor(key: "createdAt", ascending: true)
                var sortedMessages = group.messages.sortedArrayUsingDescriptors([sortByIsRead, sortByCreatedAt])
                
                objectsInTable.addObjectsFromArray(sortedMessages)
            }

        }
        
        setSelectedGroupObjectID()
    }

    func setSelectedGroupObjectID() {

        if let id = selectedGroupObjectID {
            if let group = managedObjectContext.existingObjectWithID(id, error: nil) {
                if !group.deleted {
                    return
                }
            }
        }

        if objectsInTable.count == 0 {
            selectedGroupObjectID = nil
            return
        }

        if let group = objectsInTable[0] as? Group {
            selectedGroupObjectID = group.objectID
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

    func monitorLocationOfGroup(group: Group) {
        let predicate = NSPredicate(format: "isRead == 0")
        let unreadMessages = group.messages.filteredSetUsingPredicate(predicate!)
        let locationManager = LocationManager.sharedInstance
        if group.location.uuid != "" {
            let beaconRegion = group.location.beaconRegion()
            if unreadMessages.count == 0 {
                locationManager.stopRangingBeaconRegions([beaconRegion])
                locationManager.stopMonitoringRegions([beaconRegion])
            }
            else {
                locationManager.startRangingBeaconRegions([beaconRegion])
                locationManager.startMonitoringRegions([beaconRegion])
            }
        } else {
            let circularRegion = group.location.circularRegion()
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
                    setSelectedGroupObjectID()
                } else {
                    if let group = object as? Group {
                        performSegueWithIdentifier("editGroup", sender: group)
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
        if let group = object as? Group {
            LocationManager.sharedInstance.stopMonitoringRegions([group.location.region()])
            if group.location.uuid != "" {
                LocationManager.sharedInstance.stopRangingBeaconRegions([group.location.beaconRegion()])
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
            selectedGroupObjectID = nil
            return
        }
        if let group = objectsInTable[0] as? Group {
            selectedGroupObjectID = group.objectID
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
            setSelectedGroupObjectID()
            reloadSection()
        }
    }
}

// Observe Approve Member Notification
extension HomeViewController: UIAlertViewDelegate {
    func monitorApproveMemberNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkNewMember", name: kApproveMemberNotificationName, object: nil)
    }
    
    func unmonitorApproveMemberNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kApproveMemberNotificationName, object: nil)
    }
    
    func checkNewMember() {
        if let dict = NSUserDefaults.standardUserDefaults().valueForKey("approveMember") as? [NSObject: AnyObject] {
            let title = dict["title"] as String
            let message = dict["message"] as String
            let membershipId = dict["membershipId"] as Int
            let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let approveAction = UIAlertAction(title: APPROVE, style: .Default, handler: { (action) -> Void in
                self.approveMembership(membershipId)
            })
            let rejectAction = UIAlertAction(title: REJECT, style: .Destructive, handler: { (action) -> Void in
                self.rejectMembership(membershipId)
            })
            controller.addAction(approveAction)
            controller.addAction(rejectAction)
            presentViewController(controller, animated: true, completion: nil)
            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "approveMember")
        }
    }
    
    func approveMembership(membershipId: Int) {
        let membership = Membership(id: membershipId)
        membership.approve()
    }
    
    func rejectMembership(membershipId: Int) {
        let membership = Membership(id: membershipId)
        membership.reject()
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

            handleRecordedAudio()
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
    
    func handleRecordedAudio() {
        if let objectId = selectedGroupObjectID {
            let group = managedObjectContext!.objectWithID(objectId) as Group
            createMessageForGroup(group)
            monitorLocationOfGroup(group)
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        }
    }

    func createMessageForGroup (group: Group) {
        let entityDescription = NSEntityDescription.entityForName("Message", inManagedObjectContext: managedObjectContext!)
        let message = Message(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)

        let createTime = NSDate()
        let filePathString = kApplicationPath + "/" + createTime.timeIntervalSince1970.format(".0") + ".m4a"

        let outputFileURL = NSURL(fileURLWithPath: filePathString)

        var error: NSError?
        if let recorder = recorderViewController?.recorder {
            if !NSFileManager.defaultManager().copyItemAtURL(recorder.url, toURL: outputFileURL!, error: &error) {
                println("error copying item to url: \(error?.localizedDescription)")
            } else {
                NSFileManager.defaultManager().removeItemAtURL(recorder.url, error: nil)
            }

            message.group = group

            message.group.messagesCount = NSNumber(integer: (message.group.messagesCount.integerValue + 1))
            message.name = String(format: RECORD_NAME, message.group.messagesCount)
            message.isRead = false
            message.createdAt = createTime
            message.updatedAt = createTime

            group.updatedAt = createTime

            if !managedObjectContext!.save(&error) {
                println("error saving audio: \(error?.localizedDescription)")
            }
        }
    }
}
