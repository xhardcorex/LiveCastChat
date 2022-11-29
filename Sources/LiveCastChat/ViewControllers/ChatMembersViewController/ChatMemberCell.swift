//
//  ChatMemberCell.swift
//  LiveCast
//
//  Created by Nik on 11.07.2022.
//

import UIKit

class ChatMemberCell: UITableViewCell, Identifiable {

    @IBOutlet weak var avatarImageView: AvatarImageView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var muteUnmuteActionCallback : (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(name: String?, username: String, avatar: PresignedAttachment?, isMuted: Bool) {
        avatarImageView.image = nil
        nameLabel.text = name
        usernameLabel.text = username
        muteButton.setImage(isMuted ? UIImage(systemName: "mic.slash.circle.fill") : UIImage(systemName: "mic.circle.fill"), for: .normal)
            
        if let avatar = avatar, let url = URL(string: avatar.presignedUrl) {
            avatarImageView.af.setImage(withURL: url, cacheKey: avatar.id)
        }
        //FIXME: Need to review and delete if this part is useless
//        else {
//            avatarImageView.setImage(LetterAvatarConfigurator.makeAvatar(with: username))
//        }
    }
    
    // MARK: Private Action

    @IBAction func muteUnmuteAction(_ sender: UIButton) {
        muteUnmuteActionCallback?()
    }
    
    
}
