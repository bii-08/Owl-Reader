//
//  SavedWordsListView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/05.
//

import SwiftUI
import SwiftData

struct SavedWordsListView: View {
    var wordBook: WordBook
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            List(wordBook.savedWords, id: \.self) { savedWord in
                NavigationLink(value: savedWord) {
                    VStack(alignment: .leading) {
                        Text(savedWord.word)
                            .bold()
                        
                        if let definition = savedWord.results?.first?.definition {
                            Text(definition)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
                .listRowBackground(RoundedRectangle(cornerRadius: 10).fill(Color(.savedWordRectangle)).padding(.horizontal))
                .listRowSeparator(.hidden)
                
            }
            .listStyle(.plain)
            .listRowSpacing(10)
        }
        .navigationDestination(for: Word.self) { word in
            DefinitionView(vm: DefinitionVM(selectedWord: word.word, dictionaryService: DictionaryService()), initialWordBook: wordBook.name)
        }
        .navigationTitle(wordBook.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SavedWordsListView(wordBook: WordBook(name: "Harry Potter", savedWords: [Word(word: "Pathetic", results: [Result(definition: "inspiring scornful pity", partOfSpeech: "adjective", synonyms: [
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
        ])], pronunciation: nil, frequency: 3.2)]))
    }
    .environmentObject(WordBookVM())
    .modelContainer(for: [Word.self, WordBook.self])
}
