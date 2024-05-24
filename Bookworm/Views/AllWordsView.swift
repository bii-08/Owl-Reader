//
//  RecentlyReadRowView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/10.
//

import SwiftUI
import SwiftData

struct AllWordsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @Query var allWords: [Word]
    @State private var searchQuery = ""
    @State private var showingSheet = false
    @State private var showingDefinition = false
    
    @State private var allowToDeleteWithoutAsking = UserDefaults.standard.bool(forKey: "allowToDeleteWithoutAsking")
    @State private var testing = false
    
    @State private var searchWord = ""
    @State private var showingConfirmation = false
    @State private var wordNeedToDelete: Word?
    
    var filteredWords: [Word] {
        if searchQuery.isEmpty {
            return allWords
        }
        let filteredWords = allWords.compactMap { word in
            let wordContainsQuery = word.word.range(of: searchQuery, options: .caseInsensitive) != nil
            return wordContainsQuery ? word : nil
        }
        return filteredWords
    }
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            List(filteredWords, id: \.self) { word in
                NavigationLink(value: word) {
                    VStack(alignment: .leading) {
                        Text(word.word)
                            .bold()
                        
                        if let definition = word.results?.first?.definition {
                            Text(definition)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
                .listRowBackground(RoundedRectangle(cornerRadius: 10).fill(Color(.savedWordRectangle)).padding(.horizontal))
                .listRowSeparator(.hidden)
                .swipeActions(allowsFullSwipe: false) {
                    Button {
                        if !allowToDeleteWithoutAsking {
                            wordNeedToDelete = word
                            showingConfirmation = true
                        } else {
                            modelContext.delete(word)
                        }
                        
                    } label: {
                        Label("", image: "trash")
                    }
                    .tint(.clear)
                }
                .disabled(showingConfirmation)
            }
            .searchable(text: $searchQuery, prompt: Text("Search by word")).disabled(showingConfirmation)
            .customDialog(isShowing: $showingConfirmation, dialogContent: {
                AlertView(title: "Delete word", message: "Permanently delete your word?" + "\n" + "\n" + "Deleting words from here will make your words disappeared from all your word books also.", primaryButtonTitle: "Cancel", secondaryButtonTitle: "Allow. Don't ask again.", action1: {
                    showingConfirmation = false
                    
                }, action2: {
                    UserDefaults.standard.set(true, forKey: "allowToDeleteWithoutAsking")
                    allowToDeleteWithoutAsking = true
                    if let wordNeedToDelete {
                        modelContext.delete(wordNeedToDelete)
                    }
                    showingConfirmation = false
                })
            })
            .overlay {
                if filteredWords.isEmpty && searchQuery != "" {
                    ContentUnavailableView.search(text: searchQuery)
                } else if filteredWords.isEmpty {
                    ContentUnavailableView("Empty Words", systemImage: "books.vertical.fill", description: Text("Click plus button or start browsing your webpages to add new words."))
                }
            }
            .listStyle(.plain)
            .listRowSpacing(10)
            .navigationDestination(for: Word.self) { word in
                DefinitionView(vm: DefinitionVM(selectedWord: word.word, dictionaryService: DictionaryService()))
            }
            .sheet(isPresented: Binding(get: { showingSheet }, set: { showingSheet = $0 })) {
                searchByDictionarySheet
            }
        }
        .navigationDestination(isPresented: $showingDefinition, destination: {
            DefinitionView(vm: DefinitionVM(selectedWord: searchWord.lowercased(), dictionaryService: DictionaryService()))
        })
        .onAppear {
            searchWord = ""
            if testing {
                UserDefaults.standard.removeObject(forKey: "allowToDeleteWithoutAsking")
            }
        }
        .navigationTitle("All words (\(allWords.count))")
        .toolbar {
            Button {
                showingSheet = true
            } label: {
                Image(systemName: "plus")
                    .scaleEffect(1.2)
            }
            .tint(.red)
            .disabled(showingConfirmation)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension AllWordsView {
    private var searchByDictionarySheet: some View {
        VStack(alignment: .leading) {
            Text("Add new word")
                .font(Font.custom("DIN Condensed", size: 25))
                .padding()
            TextField("", text: $searchWord, prompt: Text("Type any word...").foregroundColor(.white.opacity(0.7))).padding(6)
                .foregroundColor(.white)
                .submitLabel(.done)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color("SearchBar").opacity(0.35)))
                .padding(.horizontal)
                .presentationBackground(.thinMaterial)
                .presentationCornerRadius(15)
                .presentationDetents([.height(225)])
            
            HStack {
                Spacer()
                Button {
                    showingSheet = false
                    showingDefinition = true
                } label: {
                    Text("Search")
                        .foregroundColor(.white)
                        .frame(width: 100, height: 40)
                        .background(RoundedRectangle(cornerRadius: 5).fill(!HomeVM.isTitleValid(title: searchWord) ? Color.orange.opacity(0.2) : Color.orange))
                }
                .disabled(!HomeVM.isTitleValid(title: searchWord))
            }
            .padding()
        }
        .onAppear {
            searchWord = ""
        }
        .padding()
    }
}
#Preview {
    NavigationStack {
        AllWordsView()
            .modelContainer(for: [Link.self, Shortcut.self, Headline.self, Word.self, WordBook.self])
    }
}
