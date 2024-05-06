//
//  WorkBook.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/05.
//

import Foundation

struct WordBook: Identifiable, Hashable {
    static func == (lhs: WordBook, rhs: WordBook) -> Bool {
        lhs.name == rhs.name
    }
    
    var id: String {
        self.name
    }
    var name: String
    var savedWords : [Word]?
}
