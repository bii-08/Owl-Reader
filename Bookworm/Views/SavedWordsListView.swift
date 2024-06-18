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
    @State private var searchQuery = ""
    @State private var showingReviewAlert = false
    var filteredWords: [Word] {
        if searchQuery.isEmpty {
            return wordBook.savedWords
        }
        let filteredWords = wordBook.savedWords.compactMap { word in
            let wordContainsQuery = word.word.range(of: searchQuery, options: .caseInsensitive) != nil
            return wordContainsQuery ? word : nil
        }
        
        return filteredWords
    }
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            List(filteredWords, id: \.self) { savedWord in
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
            .searchable(text: $searchQuery, prompt: Text(Localized.Search_by_word))
            .customDialog(isShowing: $showingReviewAlert, dialogContent: {
                AlertView(title: Localized.Vocabulary_Review_Feature, message: Localized.The_vocabulary_review_feature_is_in_progress + "\n" + "\n" + Localized.We_are_working_hard_to_provide_it_as_soon_as_possible, primaryButtonTitle: Localized.Got_it) {
                    showingReviewAlert = false
                }
            })
            .overlay {
                if filteredWords.isEmpty && searchQuery != "" {
                    ContentUnavailableView.search(text: searchQuery)
                } else if filteredWords.isEmpty {
                    ContentUnavailableView(Localized.Empty_Words, systemImage: "books.vertical.fill", description: Text(Localized.Start_browsing_your_webpages_to_add_new_words))
                }
            }
            .listStyle(.plain)
            .listRowSpacing(10)
            .navigationDestination(for: Word.self) { word in
                DefinitionView(vm: DefinitionVM(selectedWord: word.word, dictionaryService: DictionaryService()), initialWordBook: wordBook.name)
            }
        }
        .navigationTitle("\(wordBook.name.truncatedText())" + " " + "(\(wordBook.savedWords.count))")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsManager.shared.logEvent(name: "SavedWordsListView_Appear")
        }
        .onDisappear {
            AnalyticsManager.shared.logEvent(name: "SavedWordsListView_Disappear")
        }
        .toolbar {
            Button {
                // TODO: navigate user to flashcard view
                showingReviewAlert = true
            } label: {
                HStack {
                    Image(systemName: "lock.fill")
                    Text(Localized.Review)
                }
            }
//            .disabled(true)
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}

//#Preview {
//    NavigationStack {
//        SavedWordsListView(wordBook: WordBook(name: "Harry Potter", savedWords: [Word(word: "Pathetic", results: [Result(definition: "inspiring scornful pity", partOfSpeech: "adjective", synonyms: [
//            "hapless",
//            "miserable",
//            "misfortunate",
//            "piteous",
//            "pitiable",
//            "pitiful",
//            "poor",
//            "wretched"
//        ], similarTo: [
//            "unfortunate"
//        ], examples: [
//            "the shabby room struck her as extraordinarily pathetic"
//        ], derivation: [
//            "pathos"
//        ])], pronunciation: nil, frequency: 3.2)]))
//    }
//    .environmentObject(WordBookVM())
//    .modelContainer(for: [Word.self, WordBook.self])
//}
