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

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, MessagesTableViewCellDelegate {

    //MARK: - Constants

    let kSlideUpToCancel = "Slide Up To Cancel"
    let kReleaseToCancel = "Release To Cancel"
    let kMinimumRecordLength = 1.0
    var kApplicationPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last! as String

    //MARK: - Variables

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pressHereImageView: UIImageView!
    var editingCellRowNumber = 0

    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var managedObjectContext = NSManagedObjectContext()
    var fetchedResultController: NSFetchedResultsController!

    var objectsInTable: NSMutableArray = []

    lazy var selectedLocationObjectID: NSManagedObjectID? = {
        [unowned self] in
        if let location = self.objectsInTable[0] as? Location {
            let objectID = location.objectID
            return objectID
        }
        else {
            return nil
        }
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
        self.navigationItem.titleView = logoImageView

        setManagedObjectContext()

        if fetchedResultController.fetchedObjects?.count == 0 {
            tableView.hidden = true
            recordButton.hidden = true
        }
        else {
            pressHereImageView.hidden = true
        }

        self.configureAudioSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - UITableViewDataSource
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

            if location.objectID == selectedLocationObjectID {
                cell.checkRadioButton()
            }
            else {
                cell.uncheckedRadioButton()
            }

            return cell
        } else {
            let message:Message = objectsInTable.objectAtIndex(indexPath.row) as Message

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

    //MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is LocationsTableViewCell {
            var locationCell: LocationsTableViewCell = cell as LocationsTableViewCell
            let location = self.objectsInTable[indexPath.row] as Location
            self.selectedLocationObjectID = location.objectID
            self.tableView.reloadData()
        } else {
            var messageCell: MessagesTableViewCell = cell as MessagesTableViewCell
            if messageCell.playing {
                messageCell.finishPlaying()
                self.stopPlayingAudio()
            } else {
                if let indexPath = self.activePlayerIndexPath {
                    let cell = self.tableView.cellForRowAtIndexPath(indexPath) as MessagesTableViewCell
                    cell.finishPlaying()
                }
                messageCell.startPlaying()
                self.playAudioAtIndexPath(indexPath)
                self.activePlayerIndexPath = indexPath
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

    //MARK: - IBActions
    //MARK: record button actions
    @IBAction func recordButtonTouchedDown(sender: UIButton) {
        self.recordAudio()
    }

    @IBAction func recordButtonTouchedUpInside(sender: UIButton) {
        self.finishRecordingAudio()
    }

    @IBAction func recordButtonTouchedUpOutside(sender: UIButton) {
        self.stopRecordingAudio()
    }

    @IBAction func recordButtonTouchedDragEnter(sender: UIButton) {
    }

    @IBAction func recordButtonTouchedDragExit(sender: UIButton) {
    }

    func tappedMessageCellAtIndexPath(indexPath: NSIndexPath) {
        println("tapped message cell at index path: \(indexPath)")

    }


    // NSFetchedResultControllerDelegate

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if self.tableView.hidden {
            self.tableView.hidden = false
            self.recordButton.hidden = false
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        setObjectsInTable()
        tableView.reloadData()
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
            let location = managedObjectContext.objectWithID(selectedLocationObjectID!) as Location
            self.createMessageForLocation(location)
            self.monitorLocation(location)
        }
        else {
            println("Record is too short")
        }
        self.timeInterval = 0
    }

    func createMessageForLocation (location: Location) {
        let entityDescription = NSEntityDescription.entityForName("Message", inManagedObjectContext: managedObjectContext)
        let message = Message(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)

        let createTime = NSDate()
        let filePathString = kApplicationPath + "/" + createTime.timeIntervalSince1970.format(".0") + ".m4a"

        let outputFileURL = NSURL(fileURLWithPath: filePathString)

        var error: NSError?
        if !NSFileManager.defaultManager().copyItemAtURL(self.recorder.url, toURL: outputFileURL, error: &error) {
            println("error copying item to url: \(error?.localizedDescription)")
        }

        message.location = location
        message.location.messageCount = message.location.messageCount + 1
        message.name = "Record \(message.location.messageCount)"
        message.isRead = false
        message.createdAt = createTime
        message.updatedAt = createTime

        if !managedObjectContext.save(&error) {
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
        let beaconRegion = location.beaconRegion()
        LocationManager.sharedInstance.startRangingBeaconRegions([beaconRegion])
        LocationManager.sharedInstance.startMonitoringBeaconRegions([beaconRegion])
    }

    func checkUnmonitorLocation(location: Location) {
        let predicate = NSPredicate(format: "isRead == 0")
        let unreadMessages = location.messages.filteredSetUsingPredicate(predicate)
        if unreadMessages.count == 0 {
            let beaconRegion = location.beaconRegion()
            let locationManager = LocationManager.sharedInstance
            locationManager.stopRangingBeaconRegions([beaconRegion])
            locationManager.stopMonitoringBeaconRegions([beaconRegion])
        }
    }
}

//MARK: - AVAudioPlayerDelegate

extension HomeViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!,
        successfully flag: Bool) {
        let cell = self.tableView.cellForRowAtIndexPath(self.activePlayerIndexPath!) as MessagesTableViewCell
        cell.finishPlaying()
        let message = self.objectsInTable[self.activePlayerIndexPath!.row] as Message
        let location = message.location
        self.checkUnmonitorLocation(location)
        self.activePlayerIndexPath = nil
        self.tableView.reloadData()
    }
}
