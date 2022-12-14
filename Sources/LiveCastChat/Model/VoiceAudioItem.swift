//
//  File.swift
//  
//
//  Created by Nik on 14.12.2022.
//

import UIKit

open class VoiceAudioItem: AudioItem {
 
    /// The url where the audio file is located.
    public var url: URL
    public var duration: Float
    public var size: CGSize
    
    public init(url: URL, duration: Float, size: CGSize) {
        self.url = url
        self.duration = duration
        self.size = size
    }
}
