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

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    //MARK: - Constants

    let kSlideUpToCancel = "Slide Up To Cancel"
    let kReleaseToCancel = "Release To Cancel"
    let kMinimumRecordLength = 1.0
    var kApplicationPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last! as String
    var hudView = HUD()
    //MARK: - Variables

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pressHereImageView: UIImageView!
    var editingCellRowNumber = -1

    weak var managedObjectContext: NSManagedObjectContext!
    var fetchedResultController: NSFetchedResultsController!

    var objectsInTable: NSMutableArray = []

    lazy var selectedLocationObjectID: NSManagedObjectID? = {
        [unowned self] in
        if self.objectsInTable.count == 0 {
            return nil
        }
        let location = self.objectsInTable[0] as Location
        return location.objectID
    }()

    var activePlayerIndexPath: NSIndexPath?

    //MARK: variables for audio recorder

    lazy var recorder: AVAudioRecorder = {
        [unowned self] in
        let path = "\(self.kApplicationPath)/memo.m4a"
        let fileURL = NSURL(fileURLWithPath: path)
        let settings = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2
        ]
        var error: NSError?
        var recorder = AVAudioRecorder(URL: fileURL, settings: settings, error: &error)
        if let e = error {
            println("error initializing recorder: \(e)")
        }
        else {
            recorder.meteringEnabled = true
            recorder.prepareToRecord()
        }
        return recorder
    }()

    lazy var startDate = NSDate()
    lazy var timer = NSTimer()
    lazy var timeInterval = NSTimeInterval()

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
        configureAudioSession()

        // detect tap gesture
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "tapView:")
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        monitorEnterLocationNotification()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        unmonitorEnterLocationNotification()
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
            if indexPath.row == editingCellRowNumber {
                swipeableCell.openCell(animated: false)
            }
        }
        return cell
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
            return cell
        }
    }

    //MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if editingCellRowNumber != -1 {
            // has editing cell, close cell
            closeEditingCell()
            return
        }

        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let locationCell = cell as? LocationsTableViewCell {
            let location = self.objectsInTable[indexPath.row] as Location
            self.selectedLocationObjectID = location.objectID
            self.tableView.reloadData()
        } else {
            let messageCell = cell as MessagesTableViewCell
            if messageCell.playing {
                messageCell.finishPlaying()
                self.stopPlayingAudio()
            } else {
                // stop any existing playing record
                if let indexPath = self.activePlayerIndexPath {
                    let cell = self.tableView.cellForRowAtIndexPath(indexPath) as MessagesTableViewCell
                    cell.finishPlaying()
                }
                messageCell.startPlaying()
                self.playAudioAtIndexPath(indexPath)
                self.activePlayerIndexPath = indexPath
                let message = objectsInTable.objectAtIndex(indexPath.row) as Message
                message.isRead = true
                message.updatedAt = NSDate()
                managedObjectContext.save(nil)
                self.monitorLocation(message.location)
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    func resetEditMode () {
        editingCellRowNumber = -1
        recordButton.enabled = true
    }

    func closeEditingCell() {
        let indexPath = NSIndexPath(forRow: editingCellRowNumber, inSection: 0)

        if let previousEditingCell = tableView.cellForRowAtIndexPath(indexPath) as? SwipeableTableViewCell {
            previousEditingCell.closeCell(animated: true)
        }
    }

    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let devicesVC = segue.destinationViewController as? DevicesTableViewController {
            devicesVC.managedObjectContext = managedObjectContext
        }
        if let editLocationVC = segue.destinationViewController as? EditLocationViewController {
            if let location = sender as? Location {
                editLocationVC.location = location
                editLocationVC.managedObjectContext = managedObjectContext
            }
        }
    }

    //MARK: - IBActions
    //MARK: record button actions
    @IBAction func recordButtonTouchedDown(sender: UIButton) {
        if editingCellRowNumber != -1 {
            closeEditingCell()
        } else {
            hudView = HUD.hudInView(view)
            hudView.text = kSlideUpToCancel
        }
        
        recordAudio()
    }

    @IBAction func recordButtonTouchedUpInside(sender: UIButton) {
        hudView.removeFromSuperview()
        finishRecordingAudio()
    }

    @IBAction func recordButtonTouchedUpOutside(sender: UIButton) {
        hudView.removeFromSuperview()
        stopRecordingAudio()
    }

    @IBAction func recordButtonTouchedDragEnter(sender: UIButton) {
        hudView.text = kSlideUpToCancel
        hudView.setNeedsDisplay()
    }

    @IBAction func recordButtonTouchedDragExit(sender: UIButton) {
        hudView.text = kReleaseToCancel
        hudView.setNeedsDisplay()
    }

    //MARK: - NSFetchedResultControllerDelegate

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if self.tableView.hidden {
            self.tableView.hidden = false
            self.recordButton.hidden = false
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        setObjectsInTable()
        tableView.reloadData()
        updateViewToBePresented()
    }
    //MARK: - Layout
    
    func updateViewToBePresented() {
        if fetchedResultController.fetchedObjects?.count == 0 {
            tableView.hidden = true
            recordButton.hidden = true
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
            var sortByCreatedAt = NSSortDescriptor(key: "createdAt", ascending: false)
            var sortedMessages = location.messages.sortedArrayUsingDescriptors([sortByIsRead, sortByCreatedAt])
            objectsInTable.addObjectsFromArray(sortedMessages)
        }
    }

    //MARK: - record audio
    func recordAudio () {
        if let player = self.player {
            if player.playing {
                player.stop()
            }
        }

        let session = AVAudioSession.sharedInstance()
        session.setActive(true, error: nil)
        self.recorder.record()
        self.startDate = NSDate()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
    }

    func configureAudioSession () {
        let session = AVAudioSession.sharedInstance()
        var error: NSError?

        if !session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: &error) {
            println("could not set session category")
            if let e = error {
                println("set session category error: \(e.localizedDescription)")
            }
        }

        if !session.setActive(true, error: &error) {
            println("could not activate session")
            if let e = error {
                println("activate session error: \(e.localizedDescription)")
            }
        }

        if !session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker, error: &error) {
            println("could not override output audio port to speaker")
            if let e = error {
                println("override output audio port error: \(e.localizedDescription)")
            }
        }
    }

    func updateTimer () {
        self.timeInterval = NSDate().timeIntervalSinceDate(self.startDate)
    }

    func finishRecordingAudio () {
        self.stopRecordingAudio()
        if self.timeInterval > kMinimumRecordLength {
            let location = managedObjectContext!.objectWithID(selectedLocationObjectID!) as Location
            self.createMessageForLocation(location)
            self.monitorLocation(location)
        }
        else {
            println("Record is too short")
        }
        self.timeInterval = 0
    }

    func createMessageForLocation (location: Location) {
        let entityDescription = NSEntityDescription.entityForName("Message", inManagedObjectContext: managedObjectContext!)
        let message = Message(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)

        let createTime = NSDate()
        let filePathString = kApplicationPath + "/" + createTime.timeIntervalSince1970.format(".0") + ".m4a"

        let outputFileURL = NSURL(fileURLWithPath: filePathString)

        var error: NSError?
        if !NSFileManager.defaultManager().copyItemAtURL(self.recorder.url, toURL: outputFileURL!, error: &error) {
            println("error copying item to url: \(error?.localizedDescription)")
        }

        message.location = location

        message.location.messageCount = NSNumber(integer: (message.location.messageCount.integerValue + 1))
        message.name = "Record \(message.location.messageCount)"
        message.isRead = false
        message.createdAt = createTime
        message.updatedAt = createTime

        if !managedObjectContext!.save(&error) {
            println("error saving audio: \(error?.localizedDescription)")
        }
    }

    func stopRecordingAudio () {
        self.recorder.stop()
        self.timer.invalidate()
    }

    //MARK: - Play Audio

    func playAudioAtIndexPath (indexPath: NSIndexPath) {
        let message = self.objectsInTable.objectAtIndex(indexPath.row) as Message
        let filePath = self.kApplicationPath + "/" + message.createdAt.timeIntervalSince1970.format(".0") + ".m4a"
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            var error: NSError?
            self.player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: filePath), error: &error)
            if let e = error {
                println("error playing audio at indexpath:\(indexPath), error: \(e.localizedDescription)")
            }
            else {
                self.player?.delegate = self
                self.player?.play()
            }
        }
    }

    func stopPlayingAudio () {
        self.player?.stop()
    }

    //MARK: - Monitor Location

    func monitorLocation(location: Location) {
        let predicate = NSPredicate(format: "isRead == 0")
        let unreadMessages = location.messages.filteredSetUsingPredicate(predicate!)
        let locationManager = LocationManager.sharedInstance
        println("location: \(location.uuid)")
        if location.uuid != "" {
            let beaconRegion = location.beaconRegion()
            if unreadMessages.count == 0 {
                locationManager.stopRangingBeaconRegions([beaconRegion])
                locationManager.stopMonitoringBeaconRegions([beaconRegion])
            }
            else {
                locationManager.startRangingBeaconRegions([beaconRegion])
                locationManager.startMonitoringBeaconRegions([beaconRegion])
            }
        }
    }
}

//MARK: - AVAudioPlayerDelegate

extension HomeViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!,
        successfully flag: Bool) {
            let cell = tableView.cellForRowAtIndexPath(activePlayerIndexPath!) as MessagesTableViewCell
            cell.finishPlaying()
            let message = self.objectsInTable[self.activePlayerIndexPath!.row] as Message
            let location = message.location
            activePlayerIndexPath = nil
            tableView.reloadData()
    }
}

//MARK: - UIGestureRecognizerDelegate

extension HomeViewController : UIGestureRecognizerDelegate {
    func tapView (recognizer: UITapGestureRecognizer) {
        closeEditingCell()
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if editingCellRowNumber != -1 {
            return true
        }
        return false
    }
}

extension HomeViewController: SwipeableTableViewCellDelegate {
    func swipeableCellDidOpen(cell: SwipeableTableViewCell) {
        closeEditingCell()

        if let indexPath = tableView.indexPathForCell(cell) {
            editingCellRowNumber = indexPath.row
        }
    }

    func swipeableCellDidClose(cell: SwipeableTableViewCell) {
        resetEditMode()
    }

    func swipeableCell(cell: SwipeableTableViewCell, didSelectButtonAtIndex index: Int) {
        resetEditMode()
        if let indexPath = tableView.indexPathForCell(cell) {
            if index == 0 {
                let object = objectsInTable.objectAtIndex(indexPath.row) as NSManagedObject
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
            } else {
                let location = objectsInTable.objectAtIndex(indexPath.row) as Location
                performSegueWithIdentifier("editLocation", sender: location)
            }
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
        if let dict = notification.userInfo as? Dictionary<String, String> {
            let title = dict["title"]
            let message = dict["message"]
            let alertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "OK")
            alertView.show()
        }
    }
}
