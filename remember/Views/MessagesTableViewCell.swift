//
//  MessagesTableViewCell.swift
//  remember
//
//  Created by Kaeli Lo on 9/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {

    @IBOutlet weak var unreadSpotIcon: UnreadSpotView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var playIcon: UIImageView!
    @IBOutlet weak var pauseIcon: UIImageView!
    @IBOutlet weak var inactiveIcon: UIImageView!
    
    enum PlayerStatus {
        case Normal, Playing
    }

    var playing: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func startPlaying() {
        unreadSpotIcon.hidden = true

        setPlayerStatus(PlayerStatus.Playing)
    }
    
    func finishPlaying() {
        setPlayerStatus(PlayerStatus.Normal)
    }
    
    func setPlayerStatus(status: PlayerStatus) {
        switch status {
        case PlayerStatus.Playing:
            playing = true
            
            playIcon.hidden = true
            pauseIcon.hidden = false
            inactiveIcon.hidden = true
        default:
            // Normal
            playing = false
            
            playIcon.hidden = false
            pauseIcon.hidden = true
            inactiveIcon.hidden = true
        }
    }
    

}
