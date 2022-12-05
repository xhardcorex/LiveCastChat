//
//  ChatImage.swift
//  LiveCast
//
//  Created by Nik on 17.10.2022.
//

import UIKit

open class ChatImage: MediaItem {
    public var url: URL?
    
    public var image: UIImage?
    
    public var placeholderImage: UIImage
    
    public var size: CGSize
    
    public init(url: URL?, size: CGSize) {
        self.url = url
        self.size = size
        self.placeholderImage = UIImage(named: "mediaPlaceholder") ?? UIImage()
    }
}
