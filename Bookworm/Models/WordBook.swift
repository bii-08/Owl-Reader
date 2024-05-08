//
//  WorkBook.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/05.
//

import Foundation

struct WordBook: Identifiable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String {
        self.name
    }
    var name: String
    var savedWords : [Word]?
}
