//
//  Headline.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/30.
//

import Foundation
import SwiftData

struct HeadlinesResultReponse: Codable {
    let articles: [Headline]
}

@Model
final class Headline: Identifiable, Codable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String {
        self.url
    }
    var author: String?
    var title: String
    var theDescription: String?
    var url: String
    var urlToImage: String
    
    enum CodingKeys: String, CodingKey {
        case id, author, title, description, url, urlToImage
    }
    
    init(author: String? = nil, title: String, description: String? = nil, url: String, urlToImage: String) {
        self.author = author
        self.title = title
        self.theDescription = description
        self.url = url
        self.urlToImage = urlToImage
    }
    
    public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(author, forKey: .author)
            try container.encode(title, forKey: .title)
            try container.encode(theDescription, forKey: .description)
            try container.encode(url, forKey: .url)
            try container.encode(urlToImage, forKey: .urlToImage)
        }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        author = try values.decode(String?.self, forKey: .author)
        title = try values.decode(String.self, forKey: .title)
        theDescription = try values.decode(String?.self, forKey: .description)
        url = try values.decode(String.self, forKey: .url)
        urlToImage = try values.decode(String.self, forKey: .urlToImage)
    }
}
