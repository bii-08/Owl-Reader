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
    var wordCount: Int
    var genre: Genre?
    var grade: Int
    var hasImage: Bool
}

extension Book {
    static var defaults: [Book] {
        [
            Book(title: "The Gift of The Magi", author: "O. Henry", wordCount: 2057, genre: .shortStory, grade: 12, hasImage: true),
            Book(title: "Friendships", author: "Jill Mountain", wordCount: 554, grade: 8, hasImage: false),
            Book(title: "Excerpt from The Time Machine", author: "H.G. Wells", wordCount: 629,genre: .science, grade: 12, hasImage: true),
            Book(title: "That Confidence (Courage) is Not Inconsistent with Caution", author: "Thomas W.Higginson", wordCount: 659, grade: 12, hasImage: false),
            Book(title: "Communicating Effectively", author: "---", wordCount: 517, grade: 7, hasImage: true)
        ]
    }
}

enum Genre: String {
    case shortStory = "Short story"
    case science = "Science"
}

enum SortOption {
    case word
    case grade
    case notSorted
    
}
