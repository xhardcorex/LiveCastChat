//
//  GifAttachment.swift
//  LiveCast
//
//  Created by Nik on 01.06.2022.
//

import Foundation

public struct GifAttachment: Codable, Equatable {
    
    enum CodingKeys: String, CodingKey {
        case gifUrl, gifWidth, gifHeight
    }

    var gifUrl = ""
    var gifWidth = 0
    var gifHeight = 0
    
    init(gifUrl: String, gifWidth: Int, gifHeight: Int) {
        self.gifUrl = gifUrl
        self.gifWidth = gifWidth
        self.gifHeight = gifHeight
    }
    
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.gifUrl = try container.decode(String.self, forKey: .gifUrl)
            self.gifWidth = try container.decode(Int.self, forKey: .gifWidth)
            self.gifHeight = try container.decode(Int.self, forKey: .gifHeight)
        } catch let error as DecodingError {
            switch error {
            case .typeMismatch(let key, let value):
                print("error \(key), value \(value) and ERROR: \(error.localizedDescription)")
            case .valueNotFound(let key, let value):
                print("error \(key), value \(value) and ERROR: \(error.localizedDescription)")
            case .keyNotFound(let key, let value):
                print("error \(key), value \(value) and ERROR: \(error.localizedDescription)")
            case .dataCorrupted(let key):
                print("error \(key), and ERROR: \(error.localizedDescription)")
            default:
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }
}
