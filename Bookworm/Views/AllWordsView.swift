//
//  RecentlyReadRowView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/10.
//

import SwiftUI
import SwiftData
import TipKit

struct AllWordsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @Query var allWords: [Word]
    @State private var searchQuery = ""
    @State private var showingSheet = false
    @State private var showingDefinition = false
    
    @State private var allowToDeleteWithoutAsking = UserDefaults.standard.bool(forKey: "allowToDeleteWithoutAsking")
    @State private var testing = false
    @State private var showingReviewAlert = false
    @State private var searchWord = ""
    @State private var showingConfirmation = false
    @State private var wordNeedToDelete: Word?
    let searchForAWordTip = DictionaryTip()
//    let requestCounterTip = RequestCounterTip()
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
    var deviceType = DeviceInfo.shared.getDeviceType()
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            listView
            .customDialog(isShowing: $showingConfirmation, dialogContent: {
                AlertView(title: Localized.Delete_word, message: Localized.Permanently_delete_your_word + "\n" + "\n" + Localized.Deleting_words_from_here_will_make_them_disappear_from_all_your_word_books_as_well, primaryButtonTitle: Localized.Cancel, secondaryButtonTitle: Localized.Allow + "\n" + Localized.Dont_ask_again, action1: {
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
            .customDialog(isShowing: $showingReviewAlert, dialogContent: {
                AlertView(title: Localized.Vocabulary_Review_Feature, message: Localized.The_vocabulary_review_feature_is_in_progress + "\n" + "\n" + Localized.We_are_working_hard_to_provide_it_as_soon_as_possible, primaryButtonTitle: Localized.Got_it) {
                    showingReviewAlert = false
                }
            })
            .overlay {
                if filteredWords.isEmpty && searchQuery != "" {
                    ContentUnavailableView.search(text: searchQuery)
                } else if filteredWords.isEmpty {
                    ContentUnavailableView(Localized.Empty_Words, systemImage: "books.vertical.fill", description: Text(Localized.Click_plus_button_or_start_browsing_your_webpages_to_add_new_words))
                }
            }
            .listStyle(.plain)
            .listRowSpacing(10)
            .navigationDestination(for: Word.self) { word in
                DefinitionView(vm: DefinitionVM(selectedWord: word.word, dictionaryService: DictionaryService()))
            }
            .popover(isPresented: Binding(get: { showingSheet }, set: { showingSheet = $0 }),attachmentAnchor: .rect(.rect(CGRect(x: 10, y: 10, width: 700, height: 300)))) {
                searchByDictionarySheet(searchForAWord: searchForAWordTip)
                    .frame(minWidth: deviceType == .pad ? 400 : 300, minHeight: deviceType == .pad ? 400 : 300)
                    .presentationDetents([.large, .height(300)])
                    .overlay(alignment: .topTrailing) {
                        HStack {
                            Spacer()
                            Button {
                                showingSheet = false
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                    .padding()
                            }
                        }
                    }
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
            AnalyticsManager.shared.logEvent(name: "AllWordsView_Appear")
        }
        .navigationTitle(Localized.All_words_lld + " " + "(\(allWords.count))")
        .toolbar {
            
            ToolbarItem(placement: .topBarLeading) {
                WordRequestCounterView()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSheet = true
                } label: {
                    Image(systemName: "plus")
                        .scaleEffect(1.2)
                }
                .popoverTip(searchForAWordTip, arrowEdge: .top)
                .tint(.red)
                .disabled(showingConfirmation || showingReviewAlert)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottomTrailing) {
            if !showingConfirmation {
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
}

extension AllWordsView {
    private var listView: some View {
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
        .searchable(text: $searchQuery, prompt: Text(Localized.Search_by_word)).disabled(showingConfirmation)
    }
    private func searchByDictionarySheet(searchForAWord: DictionaryTip) -> some View {
        VStack(alignment: .leading) {
            Text(Localized.Add_new_word)
                .font(Font.custom("DIN Condensed", size: 25))
                .padding()
            TextField("", text: $searchWord, prompt: Text(Localized.Type_any_word).foregroundColor(.white.opacity(0.7))).padding(6)
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
                    searchForAWord.invalidate(reason: .actionPerformed)
                    showingSheet = false
                    showingDefinition = true
                    AnalyticsManager.shared.logEvent(name: "AllWordsView_DictionarySearchPlusButtonClick")
                } label: {
                    Text(Localized.Search)
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
