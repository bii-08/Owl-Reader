//
//  Link.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/24.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Link: Identifiable, Codable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String {
        self.url.absoluteString
    }
    var url: URL
    @Attribute(.externalStorage) var favicon: Data?
    var webPageTitle: String
    
    enum CodingKeys: String, CodingKey {
        case id, url, favicon, webPageTitle
    }
    
    init(url: URL, favicon: Data? = nil, webPageTitle: String) {
        self.url = url
        self.favicon = favicon
        self.webPageTitle = webPageTitle
    }
    
    public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(url, forKey: .url)
            try container.encode(favicon, forKey: .favicon)
            try container.encode(webPageTitle, forKey: .webPageTitle)
        }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        url = try values.decode(URL.self, forKey: .url)
        favicon = try values.decode(Data?.self, forKey: .favicon) 
        webPageTitle = try values.decode(String.self, forKey: .webPageTitle)
    }
}




