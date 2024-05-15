//
//  WorkBook.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/05.
//

import Foundation
import SwiftData

@Model
final class WordBook: Identifiable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    
    @Attribute(.unique)
    var name: String
    
    var savedWords : [Word]
    
    init(name: String, savedWords: [Word] = []) {
        self.name = name
        self.savedWords = savedWords
    }
}

