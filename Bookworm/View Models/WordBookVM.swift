//
//  WorkBookVM.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/05.
//

import Foundation
import SwiftData


class WordBookVM: ObservableObject {
    @Published var listWordBook: [WordBook] = [WordBook(name: "Default")]
    @Published var selectedWordbook = "Default"
    @Published var showingSheet = false
    
    @Published var goodTitle = false
    @Published var message = ""
    var editingWordBook: WordBook?
  
    @Published var title: String = ""
    
    var wordBookTitle: [String] {
        listWordBook.map { $0.name }
    }
    
    init(selectedWordbook: String = "Default") {
        self.selectedWordbook = selectedWordbook
    }
   
    // FUNCTION:
    /* This is the star button which will add the word to the selected wordBook when tapped on.
     IF the word is already exists on the list, then it will be removed out of the list.
     */
    func didTapOnStar(word: Word, wordBookName: String, modelContext: ModelContext) {
        
        if let index = listWordBook.firstIndex(where: { $0.name == wordBookName }) {
            if let wordIndex = listWordBook[index].savedWords.firstIndex(where: { $0 == word }) {
                listWordBook[index].savedWords.remove(at: wordIndex)
                print("removing word")
                if !listWordBook.contains(where: { $0.savedWords.contains(word)}) {
                    modelContext.delete(word)
                }
            } else {
                listWordBook[index].savedWords.append(word)
                print("appending word")
            }
        }
        
        fetchWordBookList(modelContext: modelContext)
    }
    // FUNCTION: to check if this selected word is already saved in the selecting wordBook or not, if it is, then star color should be orange
    func isThisWordAlreadySaved(selectedWord: Word, wordBookName: String) -> Bool {
        if let index = listWordBook.firstIndex(where: { $0.name == wordBookName }) {
            if listWordBook[index].savedWords.contains(selectedWord) {
                return true
            }
        }
        return false
    }
    
    // FUNCTION: to handle editing or creating a wordBook
    func handleWordBook(wordBook: WordBook, modelContext: ModelContext) {
        // Editing word book title
        if let index = listWordBook.firstIndex(where: { $0.name == editingWordBook?.name}) {
            listWordBook[index].name = wordBook.name
        } else {
            // Creating a new word book title
            modelContext.insert(wordBook)
//            listWordBook.append(wordBook)
        }
        fetchWordBookList(modelContext: modelContext)
    }
    
    // FUNCTION: to delete wordBook
    func deleteWordBook(wordBook: WordBook, modelContext: ModelContext) {
        modelContext.delete(wordBook)
        fetchWordBookList(modelContext: modelContext)
    }
    
    // FUNCTION: to validate the wordbook title, ensure it is correct and unique before submitting
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
    
    // FUNCTION: to fetch saved wordBook list from model context.
    func fetchWordBookList(modelContext: ModelContext) {
        do {
            let descriptor = FetchDescriptor<WordBook>(sortBy: [SortDescriptor(\.name)])
            listWordBook = try modelContext.fetch(descriptor)
        } catch {
            print("Fetch failed")
        }
    }
}


