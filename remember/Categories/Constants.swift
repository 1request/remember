//
//  Constants.swift
//  remember
//
//  Created by Joseph Cheung on 14/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation

// Mixpanel Events

let kRegionType = "Region Type"
let kEventType = "Event Type"
let kRegionCenterLongitude = "Region Center Longitude"
let kRegionCenterLatitude = "Region Center Latitude"
let kSceneLongitude = "Scene Longitude"
let kSceneLatitude = "Scene Latitude"
let kSceneDescripton = "Scene description"
let kDistance = "Distance"
let kDate = "Date"
let kUUID = "iBeacon UUID"
let kMajor = "iBeacon Major"
let kMinor = "iBeacon Minor"
let kIdentifier = "Identifier"
let kArrivalDate = "Arrival Date"
let kDepartureDate = "Departure Date"
let kVisitLatitude = "Visit Latitude"
let kVisitLongitude = "Visit Longitude"
let kEnteredBeaconEventTitle = "Entered iBeacon Region"
let kExitedBeaconEventTitle = "Exited iBeacon Region"
let kEnteredGeoEventTitle = "Entered Geographic Region"
let kExitedGeoEventTitle = "Exited Geographic Region"
let kVisitArrivalEventTitle = "Visit Arrival"
let kVisitDepartureEventTitle = "Visit Departure"
let kAddLocationEventTitle = "Added Location"
let kAddGroupEventTitle = "Added Group"
let kVisitType = "Visit Type"

// NSNotification
let kAlertLocationNotificationName = "kAlertLocationNotification"
let kApproveMemberNotificationName = "kApproveMemberNotification"
let kEnteredRegionNotificationName = "enteredRegionNotification"
let kEnteredRegionNotificationUserInfoRegionKey = "region"
let kExitedRegionNotificationName = "exitedRegionNotification"
let kExitedRegionNotificationUserInfoRegionKey = "region"
let kRangedBeaconRegionNotificationName = "rangedBeaconNotification"
let kRangedBeaconRegionNotificationUserInfoBeaconsKey = "beacons"
let kGPSLocationUpdateNotificationName = "gpsLocationUpdateNotification"
let kGPSLocationUpdateNotificationUserInfoLocationKey = "location"
let kVisitsNotificationName = "visitNotification"
let kVisitsNotificationUserInfoVisitKey = "visit"

//API
#if DEBUG
    let kUsersURL = "http://dev.rememberthere.com:3000/users"
    let kGroupsURL = "http://dev.rememberthere.com:3000/groups"
    let kMembershipsURL = "http://dev.rememberthere.com:3000/memberships"
    let kAudiosURL = "http://dev.rememberthere.com:3000/audios"
    let kUnregisterURL = "http://dev.rememberthere.com:3000/memberships/unregister"
    let kAcceptURL = "http://dev.rememberthere.com:3000/memberships/accept"
    let kRejectURL = "http://dev.rememberthere.com:3000/memberships/reject"
#else
    let kUsersURL = "http://app.rememberthere.com/users"
    let kGroupsURL = "http://app.rememberthere.com/groups"
    let kMembershipsURL = "http://app.rememberthere.com/memberships"
    let kAudiosURL = "http://app.rememberthere.com/audios"
    let kUnregisterURL = "http://app.rememberthere.com/memberships/unregister"
    let kAcceptURL = "http://app.rememberthere.com/memberships/accept"
    let kRejectURL = "http://app.rememberthere.com/memberships/reject"
#endif

let kFeedbackPOSTURL = "http://app.rememberthere.com/api/feedbacks/send"
let kBoundary = "testboundary"

//HUD
let SLIDE_UP_TO_CANCEL = NSLocalizedString("SLIDE_UP_TO_CANCEL", comment: "Inform user to slide up to cancel recording")
let RELEASE_TO_CANCEL = NSLocalizedString("RELEASE_TO_CANCEL", comment: "Inform user to release finger to cancel recording")
let RECORD_NAME = NSLocalizedString("RECORD_NAME", comment: "default message name")

//File Path
let kApplicationPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last! as String
