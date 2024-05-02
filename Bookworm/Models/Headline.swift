//
//  Headline.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/30.
//

import Foundation

struct HeadlinesResultReponse: Codable {
    let articles: [Headline]
}
struct Headline: Identifiable, Codable, Hashable {
    var id: String {
        self.url
    }
    var author: String?
    var title: String
    var description: String?
    var url: String
    var urlToImage: String
}
