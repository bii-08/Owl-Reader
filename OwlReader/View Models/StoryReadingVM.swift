//
//  StoryReadingVM.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/06.
//

import Foundation
import Firebase

@MainActor
class StoryReadingVM: ObservableObject {
    @Published var selectedWord: String?
    @Published var content: String?
    @Published var words: [String] = []
    var book: Book
    
    init(book: Book) {
        self.book = book
        self.content = book.content
//        loadTextFile(named: book.title)
    }
    
    func loadTextFile(named name: String) {
        if let filePath = Bundle.main.path(forResource: name, ofType: "txt") {
            do {
                let fullText = try String(contentsOfFile: filePath, encoding: .utf8)
                if let startRange = fullText.range(of: "*** START OF THE PROJECT GUTENBERG EBOOK \(book.title.uppercased()) ***"),
                   let endRange = fullText.range(of: "*** END OF THE PROJECT GUTENBERG EBOOK \(book.title.uppercased()) ***") {
                    let startIndex = fullText.index(after: startRange.upperBound)
                    let endIndex = endRange.lowerBound
                    print("---> Successfully loaded text file")
                    let extractedText = String(fullText[startIndex..<endIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
                    DispatchQueue.main.async {
                        var newText = extractedText.replacingOccurrences(of: "\r\n\r\n", with: " <break> ")
                        newText = newText.replacingOccurrences(of: "\r\n", with: " ")
                        self.content = newText
                    }
                }
                
            } catch {
                print("---> Error reading file: \(error)")
            }
        } else {
            print("---> File not found")
        }
    }
    
    
}
