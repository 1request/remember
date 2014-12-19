//
//  GroupInformationView.swift
//  remember
//
//  Created by Joseph Cheung on 18/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit
import MapKit

@IBDesignable
class GroupInformationView: PopUpView {
    lazy var mapView: MKMapView = {
        let view = MKMapView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
        }()
    
    lazy var groupNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.appGreenTextColor()
        label.font = UIFont.boldSystemFontOfSize(17)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.text = "Group Name"
        return label
        }()
    
    lazy var imagesCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewRightAlignedLayout()
        flowLayout.itemSize = CGSizeMake(50, 50)
        flowLayout.scrollDirection = .Vertical
        let view = UICollectionView(frame: self.frame, collectionViewLayout: flowLayout)
        view.backgroundColor = UIColor.whiteColor()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
        }()
    
    var annotation: MKAnnotation? {
        didSet {
            mapView.addAnnotation(annotation)
        }
    }
    
    var region: MKCoordinateRegion? {
        didSet {
            mapView.region = region!
        }
    }
    
    override func setup() {
        super.setup()
        frameView.addSubview(mapView)
        frameView.addSubview(groupNameLabel)
        frameView.addSubview(imagesCollectionView)
        
        let viewsDict = ["mapView": mapView, "groupNameLabel": groupNameLabel, "collectionView": imagesCollectionView]
        
        let mapViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[mapView]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: viewsDict)
        
        let mapViewVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[mapView]-[groupNameLabel]-[collectionView]|", options: .DirectionLeadingToTrailing, metrics: nil, views: viewsDict)
        
        let mapViewHeightConstraint = NSLayoutConstraint(item: mapView, attribute: .Height, relatedBy: .Equal, toItem: frameView, attribute: .Height, multiplier: 0.7, constant: 0)
        
        let groupNameLabelHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[groupNameLabel]", options: .DirectionLeadingToTrailing, metrics: nil, views: viewsDict)
        
        let imagesCollectionViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[collectionView]-|", options: .DirectionLeadingToTrailing, metrics: nil, views: viewsDict)
        
        frameView.addConstraint(mapViewHeightConstraint)
        frameView.addConstraints(mapViewHorizontalConstraints)
        frameView.addConstraints(mapViewVerticalConstraints)
        frameView.addConstraints(groupNameLabelHorizontalConstraints)
        frameView.addConstraints(imagesCollectionViewHorizontalConstraints)
    }
}
