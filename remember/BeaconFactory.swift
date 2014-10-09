//
//  BeaconFactory.swift
//  remember
//
//  Created by Joseph Cheung on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import Foundation
import CoreLocation

class BeaconFactory {
    class func beaconRegionsToBeRanged () -> [CLBeaconRegion] {
        var beaconDetails:[CLBeaconRegion] = []
        
        beaconDetails.append(CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"), identifier: "Radius Network 2F234454"))
        beaconDetails.append(CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"), identifier: "AirLocate E2C56DB5"))
        beaconDetails.append(CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"), identifier: "AirLocate 5A4BCFCE"))
        beaconDetails.append(CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "74278BDA-B644-4520-8F0C-720EAF059935"), identifier: "AirLocate 74278BDA"))
        beaconDetails.append(CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "00000000-0000-0000-0000-000000000000"), identifier: "Null iBeacon 00000000"))
        beaconDetails.append(CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "5AFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"), identifier: "RedBear 5AFFFFFF"))
        beaconDetails.append(CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "92AB49BE-4127-42F4-B532-90FAF1E26491"), identifier: "TwoCanoes 92AB49BE"))
        beaconDetails.append(CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D"), identifier: "RedBear B9407F30"))
        beaconDetails.append(CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "52414449-5553-4E45-5457-4F524B53434F"), identifier: "Radius Network 52414449"))
        
        return beaconDetails
    }
}