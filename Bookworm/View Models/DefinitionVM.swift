//
//  DefinitionVM.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/03.
//

import Foundation

@MainActor
class DefinitionVM: ObservableObject {
    private let dictionaryService: DictionaryServiceDelegate
    @Published var word: Word?
    var selectedWord: String
    
    // NOTE: Replace MockdataForWord() with DictionaryService() to fetch data from real API
    init(selectedWord: String, dictionaryService: DictionaryServiceDelegate = MockdataForWord()) {
        self.selectedWord = selectedWord
        self.dictionaryService = dictionaryService
        
        Task {
            await fetchWord()
        }
    }
    
    // FUNCTION: for fetching word from dictionary api
    func fetchWord() async {
        if let targetWord: Word = await dictionaryService.downloadWord(word: selectedWord) {
            word = targetWord
            print(word as Any)
        }
    }
    
    // Function to capitalize the first letter of a string
    func capitalizeFirstLetter(of string: String) -> String {
        // Return the capitalized version of the string
        return string.prefix(1).capitalized + string.dropFirst()
    }
}
