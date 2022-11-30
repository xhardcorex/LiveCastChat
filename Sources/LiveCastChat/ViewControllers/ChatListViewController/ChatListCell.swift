//
//  ChatListCell.swift
//  LiveCast
//
//  Created by Nik on 23.09.2022.
//

import UIKit

class ChatListCell: UITableViewCell, Identifiable {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avatarImageView: AvatarImageView!
    @IBOutlet weak var statusImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(username: String, lastMessage: String, date: String, avatar: String?, isOnline: Int) {
        usernameLabel.text = username
        lastMessageLabel.text = lastMessage
        dateLabel.text = date
        
        if let avatar = avatar, let url = URL(string: avatar) {
            avatarImageView.af.setImage(withURL: url, cacheKey: nil)
        } else {
//            avatarImageView.setImage(LetterAvatarConfigurator.makeAvatar(with: username))
        }
        
        statusImageView.image = UIImage(named: isOnline == 1 ? "dot_online" : "dot_offline")

    }
    
}
