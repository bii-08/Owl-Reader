//
//  DefinitionVM.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/03.
//

import Foundation

@MainActor
class DefinitionVM: ObservableObject {
    private let webService: WebServiceDelegate
    @Published var word: Word?
    var selectedWord: String
    
    init(selectedWord: String, webService: WebServiceDelegate = MockdataForWord()) {
        self.selectedWord = selectedWord
        self.webService = webService
        
        Task {
            await fetchWord()
        }
    }
    
    
    // FUNCTION: for fetching word from dictionary api
        func fetchWord() async {
            if let targetWord: Word = await webService.downloadData(fromURL: "https://wordsapiv1.p.mashape.com/words/\(String(describing: selectedWord))") {
                word = targetWord
//                print(word as Any)
            }
        }
    
    // Function to capitalize the first letter of a string
        func capitalizeFirstLetter(of string: String) -> String {
            // Return the capitalized version of the string
            return string.prefix(1).capitalized + string.dropFirst()
        }
}
