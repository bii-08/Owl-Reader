//
//  Shortcut.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/24.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Shortcut: Identifiable, Codable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String {
        self.url.absoluteString
    }
    @Attribute(.unique)
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

extension Shortcut {
    static var defaults: [Shortcut] {
        [.init(url: URL(string: "https://breakingnewsenglish.com/")!, favicon: UIImage(named: "breakingNewsEnglish-19b")?.pngData(), webPageTitle: "BreakingNewsEnglish"),
         .init(url: URL(string: "https://www.theguardian.com/")!, favicon: UIImage(named: "guardian-8g")?.pngData(), webPageTitle: "Guardian"),
         .init(url: URL(string: "https://qz.com/")!, favicon: UIImage(named: "quartz-6q")?.pngData(), webPageTitle: "Quartz"),
         .init(url: URL(string: "https://www.huffpost.com/")!, favicon: UIImage(named: "huffpost-8h")?.pngData(), webPageTitle: "Huffpost"),
         .init(url: URL(string: "https://www.aljazeera.com/")!, favicon: UIImage(named: "aljazeera-9a")?.pngData(), webPageTitle: "Aljazeera")
         ]
    }
}


