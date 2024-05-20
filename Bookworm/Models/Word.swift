//
//  Word.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/03.
//

import Foundation
import SwiftData

// MARK: - Word
@Model
final class Word: Codable , Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(word)
    }
    @Attribute(.unique)
    let word: String
    
    var results: [Result]?
    var pronunciation: Pronunciation?
    let frequency: Double?
    
    @Relationship(deleteRule: .nullify, inverse: \WordBook.savedWords)
    var wordBooks: [WordBook]? = nil
    
    enum CodingKeys: String, CodingKey {
        case word, results, pronunciation, frequency, wordBooks
    }
    init(word: String, results: [Result]?, pronunciation: Pronunciation?, frequency: Double?, wordBooks: [WordBook]? = nil) {
        self.word = word
        self.results = results
        self.pronunciation = pronunciation
        self.frequency = frequency
        self.wordBooks = wordBooks
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(word, forKey: .word)
        try container.encode(results, forKey: .results)
        try container.encode(pronunciation, forKey: .pronunciation)
        try container.encode(frequency, forKey: .frequency)
    }
    
    required init(from decoder: Decoder)  throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        word = try values.decode(String.self, forKey: .word)
        do {
            results = try values.decode([Result]?.self, forKey: .results)
        } catch {
            results = []
        }
        do {
            let string = try values.decodeIfPresent(String.self, forKey: .pronunciation)
            pronunciation = Pronunciation(all: string ?? "")
        } catch DecodingError.typeMismatch {
            pronunciation = try values.decodeIfPresent(Pronunciation.self, forKey: .pronunciation)
        }
//        pronunciation = try values.decodeIfPresent(Pronunciation.self, forKey: .pronunciation)
        frequency = try values.decodeIfPresent(Double.self, forKey: .frequency)
    }
}

// MARK: - Pronunciation
struct Pronunciation: Codable, Hashable {
    let all: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(all)
    }
}

// MARK: - Result
struct Result: Codable, Hashable {
    let definition: String?
    let partOfSpeech: String?
    let synonyms: [String]?
    let similarTo: [String]?
    let examples: [String]?
    let derivation: [String]?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(definition)
    }
}
