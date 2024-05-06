//
//  Word.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/03.
//

import Foundation

// MARK: - Word
struct Word: Codable , Hashable {
    static func == (lhs: Word, rhs: Word) -> Bool {
        lhs.word == rhs.word
    }
    
    let word: String
    let results: [Result]?
//    let syllables: Syllables?
    let pronunciation: Pronunciation?
    let frequency: Double?
}

// MARK: - Pronunciation
struct Pronunciation: Codable, Hashable {
    let all: String
}

// MARK: - Result
struct Result: Codable, Hashable {
    let definition: String?
    let partOfSpeech: String?
    let synonyms: [String]?
    let similarTo: [String]?
    let examples: [String]?
    let derivation: [String]?
}

// MARK: - Syllables
//struct Syllables: Codable {
//    let count: Int
//    let list: [String]
//}
