//
//  GroupInformationViewController.swift
//  remember
//
//  Created by Joseph Cheung on 18/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import MapKit

protocol GroupInformationViewControllerDelegate {
    func groupInformationViewControllerCloseButtonPressed()
}

class GroupInformationViewController: UIViewController {

    @IBOutlet weak var groupInformationView: GroupInformationView!
    
    var delegate: GroupInformationViewControllerDelegate?
    
    var imagesUrls: [NSURL] = [NSURL]() {
        didSet {
            groupInformationView.imagesCollectionView.reloadData()
        }
    }
    
    var group: Group? {
        didSet {
            if let currentGroup = group {
                groupInformationView.groupNameLabel.text = currentGroup.name
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(currentGroup.location.latitude), longitude: CLLocationDegrees(currentGroup.location.longitude))
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                groupInformationView.annotation = annotation
                
                let span = MKCoordinateSpanMake(0.03, 0.03)
                let region = MKCoordinateRegionMake(coordinate, span)
                groupInformationView.region = region

                let url = NSURL(string: kGroupsURL + "/\(currentGroup.serverId)")!
                
                APIManager.sendRequest(toURL: url, method: .GET, json: nil) { [weak self] (response, error, jsonObject) -> Void in
                    if let weakself = self {
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            weakself.imagesUrls = map(jsonObject["accepted_members"]) {(index, user) -> NSURL in
                                return NSURL(string: kAPIUrl + user["profile_picture_url"].stringValue)!
                            }
                            let creatorImageUrl = NSURL(string: kAPIUrl + jsonObject["creator_profile_url"].stringValue)!
                            weakself.imagesUrls.append(creatorImageUrl)
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        groupInformationView.popUpDelegate = self
        groupInformationView.imagesCollectionView.dataSource = self
        groupInformationView.imagesCollectionView.registerClass(UserImageCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }
}

extension GroupInformationViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesUrls.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as UserImageCollectionViewCell
        let imageUrl = imagesUrls[indexPath.row]
        cell.imageView.sd_setImageWithURL(imageUrl, placeholderImage: UIImage(named: "device"))
        cell.layer.cornerRadius = cell.frame.size.width / 2.0
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
}

extension GroupInformationViewController: PopUpViewDelegate {
    func closeButtonPressed() {
        delegate?.groupInformationViewControllerCloseButtonPressed()
        imagesUrls.removeAll()
    }
}