//
//  Badge.swift
//  LiveCast
//
//  Created by vladimir.kuzomenskyi on 03.02.2022.
//

import Foundation

struct Badge: Codable {

    var id: Int
    var title: String
    var imageURL: URL? = nil
    var isFollowing: Bool = false

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .name)
    }
}


extension Badge {
    private enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
