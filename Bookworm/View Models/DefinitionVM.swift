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
    
    @Published var requestLimit: Int {
        didSet {
            print("------>Request Limit: \(requestLimit)")
        }
    }
    @Published var requestCount: Int {
        didSet {
            print("------>Request used: \(requestCount)")
        }
    }
    
    @Published var canMakeRequest: Bool = false
    private let requestCountKey = "requestCount"
    private let requestLimitKey = "requestLimit"
    private let lastFetchDate = "lastFetchDateForDefinition"
    
    @Published var loadingState = LoadingStateManager.loading
    
    // NOTE: Replace MockdataForWord() with DictionaryService() to fetch data from real API
    init(selectedWord: String, dictionaryService: DictionaryServiceDelegate = DictionaryService()) {
        self.selectedWord = selectedWord
        self.dictionaryService = dictionaryService
        self.requestCount = UserDefaults.standard.integer(forKey: requestCountKey)
        self.requestLimit = UserDefaults.standard.integer(forKey: requestLimitKey)
        self.canMakeRequest = requestLimit > 0
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
                calculateRequestCountAndRequestLimit()
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
    
    // FUNCTION: to calculate request count and request limit
    func calculateRequestCountAndRequestLimit() {
        requestCount += 1
        requestLimit -= 1
        UserDefaults.standard.set(requestCount, forKey: requestCountKey)
        UserDefaults.standard.set(requestLimit, forKey: requestLimitKey)
        if requestLimit == 0 {
            canMakeRequest = false
        }
    }
    
    // FUNCTION: to reset requestCount and requestLimit if needed
    func resetCountIfNeeded() {
        let today = Date().formatted(date: .numeric, time: .omitted)
        let lastFetchDate = UserDefaults.standard.string(forKey: lastFetchDate)
        print("the last fetch date: \(String(describing: lastFetchDate))")
        if lastFetchDate != today || lastFetchDate == nil {
            UserDefaults.standard.set(0, forKey: requestCountKey)
            requestCount = 0
            UserDefaults.standard.set(1, forKey: requestLimitKey)
            requestLimit = 1
            UserDefaults.standard.set(today, forKey: "lastFetchDateForDefinition")
            self.canMakeRequest = true
        }
    }
}
