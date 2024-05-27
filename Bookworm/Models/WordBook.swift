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
    var isDefault: Bool
    @Attribute(.unique)
    var name: String
    
    var savedWords : [Word]
    
    init(name: String, isDefault: Bool = false, savedWords: [Word] = []) {
        self.name = name
        self.isDefault = isDefault
        self.savedWords = savedWords
    }
}

