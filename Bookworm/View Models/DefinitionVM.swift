//
//  DefinitionVM.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/03.
//

import Foundation
import SwiftData

@MainActor
class DefinitionVM: ObservableObject {
    private let dictionaryService: DictionaryServiceDelegate
    @Published var word: Word? {
        didSet {
//            print(word?.word)
        }
    }
    var selectedWord: String
    var isNewWord = false
    
    @Published var loadingState = LoadingStateManager.loading
    
    // NOTE: Replace MockdataForWord() with DictionaryService() to fetch data from real API
    init(selectedWord: String, dictionaryService: DictionaryServiceDelegate = DictionaryService()) {
        self.selectedWord = selectedWord
        self.dictionaryService = dictionaryService
    }
    
    // FUNCTION: to fetch word from dictionary api
    func fetchWordFromAPI(modelContext: ModelContext) async {
        if !fetchWordFromDatabase(selectedWord: selectedWord, modelContext: modelContext) {
            loadingState = LoadingStateManager.loading
            if let targetWord: Word = await dictionaryService.downloadWord(word: selectedWord) {
                word = targetWord
                loadingState = LoadingStateManager.success
                print("Successfully downloaded this word from api.")
            } else {
                loadingState = LoadingStateManager.failed
                print("Failed to download this word from api!")
            }
        }
    }
    
    // FUNCTION: to capitalize the first letter of a string
    func capitalizeFirstLetter(of string: String) -> String {
        // Return the capitalized version of the string
        return string.prefix(1).capitalized + string.dropFirst()
    }
    
    // FUNCTION: to fetch word from database
    func fetchWordFromDatabase(selectedWord: String, modelContext: ModelContext) -> Bool {
        loadingState = LoadingStateManager.loading
        do {
            let predicate = #Predicate<Word> { word in
                word.word == selectedWord
            }
            let descriptor = FetchDescriptor(predicate: predicate)
            let words = try modelContext.fetch(descriptor)
                self.word = words.first
            loadingState = LoadingStateManager.success
            print("Successfully fetched word from database.")
            if word == nil {
                return false
            }
        } catch {
            loadingState = LoadingStateManager.failed
            print("Failed to fetched this word from database!")
            return false
        }
        return true
    }
}
