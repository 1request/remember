//
//  GPSSettingsViewController.swift
//  remember
//
//  Created by Joseph Cheung on 12/11/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import CoreLocation

class GPSSettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var accuracyPickerView: UIPickerView!
    
    @IBOutlet weak var filterPickerView: UIPickerView!
    
    let accuracyOptions = ["Best", "Nearest ten meters", "Hundred meters", "Kilometer", "Three kilometers"]
    let filterOptions = ["No filter", "10 meters", "100 meters", "300 meters", "500 meters"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accuracyPickerView.dataSource = self
        accuracyPickerView.delegate = self
        
        filterPickerView.dataSource = self
        filterPickerView.delegate = self
    }
    
    //MARK: - UIPickerViewDataSource

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    //MARK: - UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView.tag == 0 {
            return accuracyOptions[row]
        } else {
            return filterOptions[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            switch row {
            case 0:
                LocationManager.sharedInstance.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            case 1:
                LocationManager.sharedInstance.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            case 2:
                LocationManager.sharedInstance.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            case 3:
                LocationManager.sharedInstance.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            case 4:
                LocationManager.sharedInstance.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            default: ()
            }
        } else {
            switch row {
            case 0:
                LocationManager.sharedInstance.locationManager.distanceFilter = 0
            case 1:
                LocationManager.sharedInstance.locationManager.distanceFilter = 10
            case 2:
                LocationManager.sharedInstance.locationManager.distanceFilter = 100
            case 3:
                LocationManager.sharedInstance.locationManager.distanceFilter = 300
            case 4:
                LocationManager.sharedInstance.locationManager.distanceFilter = 500
            default: ()
            }
        }
        LocationManager.sharedInstance.stopUpdatingLocation()
        LocationManager.sharedInstance.startUpdatingLocation()
    }
}