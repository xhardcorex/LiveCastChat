//
//  ChatImage.swift
//  LiveCast
//
//  Created by Nik on 17.10.2022.
//

import UIKit

class ChatImage: MediaItem {
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    init(url: URL?, size: CGSize) {
        self.url = url
        self.size = size
        self.placeholderImage = UIImage(named: "mediaPlaceholder") ?? UIImage()
    }
}
