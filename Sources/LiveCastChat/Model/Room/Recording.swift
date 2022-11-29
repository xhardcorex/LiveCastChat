//
//  Recording.swift
//  LiveCast
//
//  Created by Nik on 25.10.2022.
//

import Foundation

class Recording: Codable {

    var recordingUrl: String
    var recordinFullPath: String
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        recordingUrl = try container.decode(String.self, forKey: .recordingUrl)
        recordinFullPath = ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(recordingUrl, forKey: .recordingUrl)
    }
}

extension Recording {
    private enum CodingKeys: String, CodingKey {
        case recordingUrl
    }
}
