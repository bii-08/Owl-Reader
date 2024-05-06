//
//  WorkBookVM.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/05.
//

import Foundation

class WordBookVM: ObservableObject {
    @Published var listWordBook: [WordBook] = [WordBook(name: "Default"), WordBook(name: "Harry Potter", savedWords: [Word(word: "Pathetic", results: [Result(definition: "inspiring scornful pity", partOfSpeech: "adjective", synonyms: [
        "hapless",
        "miserable",
        "misfortunate",
        "piteous",
        "pitiable",
        "pitiful",
        "poor",
        "wretched"
      ], similarTo: [
        "unfortunate"
      ], examples: [
        "the shabby room struck her as extraordinarily pathetic"
      ], derivation: [
        "pathos"
      ])], pronunciation: nil, frequency: 3.2)]), WordBook(name: "Animal Farm")]
    var wordBook: WordBook?
    
}
