//
//  UserImageCollectionViewCell.swift
//  remember
//
//  Created by Joseph Cheung on 19/12/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class UserImageCollectionViewCell: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
        }()
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        clipsToBounds = true
        addSubview(imageView)
        let viewsDict = ["imageView": imageView]
        let imageViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: .DirectionLeadingToTrailing, metrics: nil, views: viewsDict)
        let imageViewVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: .DirectionLeadingToTrailing, metrics: nil, views: viewsDict)
        addConstraints(imageViewHorizontalConstraints)
        addConstraints(imageViewVerticalConstraints)
    }
}
