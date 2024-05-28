//
//  DefinitionVM.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/03.
//

import Foundation
import SwiftData
import NaturalLanguage

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
    var stemForm = ""
    
    private var requestLimit = 7
    private let defaults = UserDefaults.standard
    private let requestCountKey = "requestCount"
    private let requestDateKey = "requestDate"
    @Published var requestCount: Int = 0 {
        didSet {
            print("\(requestCount)")
        }
    }
    @Published var canMakeRequest: Bool = false
    
    @Published var loadingState = LoadingStateManager.loading
    
    // NOTE: Replace MockdataForWord() with DictionaryService() to fetch data from real API
    init(selectedWord: String, dictionaryService: DictionaryServiceDelegate = DictionaryService()) {
        self.selectedWord = selectedWord
        self.dictionaryService = dictionaryService
        self.requestCount = defaults.integer(forKey: requestCountKey)
        self.canMakeRequest = requestCount < requestLimit
        
        resetCountIfNeeded()
    }
    
    // FUNCTION: to fetch word from dictionary api
    func fetchWordFromAPI(modelContext: ModelContext) async {
        if !fetchWordFromDatabase(selectedWord: selectedWord.lemmatize(), modelContext: modelContext) {
                print("------> \(selectedWord.lemmatize())")
            guard canMakeRequest else {
                loadingState = LoadingStateManager.restricted
                return
            }
            loadingState = LoadingStateManager.loading
            
            if let targetWord: Word = await dictionaryService.downloadWord(word: selectedWord.lemmatize()) {
                word = targetWord
                loadingState = LoadingStateManager.success
                incrementRequestCount()
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
    
    
    func incrementRequestCount() {
        requestCount += 1
        requestLimit = requestLimit - requestCount
        defaults.set(requestCount, forKey: requestCountKey)
        if requestLimit == 0 {
            canMakeRequest = false
        }
    }
    
    func resetCountIfNeeded() {
        let lastDate = defaults.object(forKey: requestDateKey) as? Date ?? Date.distantPast
        let currentDate = Date()
        if !Calendar.current.isDate(lastDate, inSameDayAs: currentDate) {
            defaults.set(0, forKey: requestCountKey)
            defaults.set(currentDate, forKey: requestDateKey)
        }
    }
}
