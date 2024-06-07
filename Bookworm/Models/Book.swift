//
//  Book.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/05.
//

import Foundation

struct Book: Identifiable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    var id: String {
        title
    }
    var title: String
    var author: String
}

extension Book {
    static var defaults: [Book] {
        [
            Book(title: "The Monkey's paw", author: "W. W. Jacobs"),
            Book(title: "The Gift of The Magi", author: "O. Henry"),
            Book(title: "Metamorphosis", author: "Franz Kafka"),
            Book(title: "The Yellow Wallpaper", author: "Charlotte Perkins Gilman")
        ]
    }
}
