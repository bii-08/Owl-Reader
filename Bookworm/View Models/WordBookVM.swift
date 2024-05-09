//
//  WorkBookVM.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/05.
//

import Foundation

class WordBookVM: ObservableObject {
    @Published var listWordBook: [WordBook] = [WordBook(name: "Default"), WordBook(name: "Harry Potter"), WordBook(name: "Animal Farm")]
    @Published var selectedWordbook = "Default"
    @Published var showingSheet = false
    
    @Published var goodTitle = false
    @Published var message = ""
    var editingWordBook: WordBook?
    @Published var title: String = ""
    
    
    var wordBookTitle: [String] {
        listWordBook.map { $0.name }
    }
    
    func didTapOnStar(word: Word, wordBookName: String) {
        if let index = listWordBook.firstIndex(where: { $0.name == wordBookName }) {
            if let wordIndex = listWordBook[index].savedWords?.firstIndex(where: { $0 == word }) {
                listWordBook[index].savedWords?.remove(at: wordIndex)
                print("removing word")
            } else {
                if listWordBook[index].savedWords != nil {
                    listWordBook[index].savedWords?.append(word)
                } else {
                    listWordBook[index].savedWords = [word]
                }
                
                print("appending word")
            }
        }
    }
    
    func isAlreadySaved(selectedWord: Word, wordBookName: String) -> Bool {
        if let index = listWordBook.firstIndex(where: { $0.name == wordBookName }) {
            if let savedWords = listWordBook[index].savedWords {
                if savedWords.contains(selectedWord) {
                    return true
                }
            }
        }
        return false
    }
    
    func handleWordBook(wordBook: WordBook) {
        // Editing word book title
        if let index = listWordBook.firstIndex(where: { $0.name == editingWordBook?.name}) {
            listWordBook[index].name = wordBook.name
        } else {
            // Creating a new word book title
            listWordBook.append(wordBook)
        }
    }
    
    func deleteWordBook(wordBook: WordBook) {
        listWordBook.removeAll(where: { $0.name == wordBook.name })
    }
    
    func validateTitle(title: String) -> Bool {
        if listWordBook.contains(where: { $0.name == title }) {
            message = "Sorry. This title is already taken."
            return false
        } else if !HomeVM.isTitleValid(title: title) {
            message = ""
            return false
        } else {
            return true
        }
    }
}

