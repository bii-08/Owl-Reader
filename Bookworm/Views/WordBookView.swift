//
//  WorkBookView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/05.
//

import SwiftUI
import SwiftData
import TipKit

struct WordBookView: View {
    @EnvironmentObject var vm: WordBookVM
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var addingWordBookTitle: String = ""
    
    var title: String?
    let createWordbookTip = CreateWordBookTip()
    let swipeActionTip = SwipeActionInWordBookTip()
    var deviceType = DeviceInfo.shared.getDeviceType()
    var body: some View {
        NavigationStack {
            ZStack {
                Color("background").ignoresSafeArea()
                VStack {
                    List {
                        if vm.listWordBook.count == 2 {
                            TipView(swipeActionTip)
                                .tipBackground(Color("headlineRounded"))
                                .listRowBackground(Color("background"))
                        }
                        
                        ForEach(vm.listWordBook, id: \.self) { wordBook in
                            NavigationLink(value: wordBook) {
                                HStack {
                                    Text(wordBook.name)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    
                                    Text(wordBook.savedWords.count == 0 ? "" : "\(wordBook.savedWords.count)")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .listRowBackground(Color("background"))
                            .swipeActions(allowsFullSwipe: false) {
                                if !wordBook.isDefault {
                                    // Delete Button
                                    Button(role: .destructive) {
                                        vm.deleteWordBook(wordBook: wordBook, modelContext: modelContext)
                                    } label: {
                                        Label(Localized.Delete, systemImage: "trash")
                                    }
                                    .tint(.red)
                                    
                                    // Edit Button
                                    Button {
                                        vm.showingSheet = true
                                        vm.editingWordBook = wordBook
                                    } label: {
                                        Label(Localized.Edit, systemImage: "pencil")
                                    }
                                    .tint(.orange)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .popover(isPresented: $vm.showingSheet,attachmentAnchor: .rect(.rect(CGRect(x: 10, y: 10, width: 700, height: 300)))) {
                        changingWordBookSheetView(createWordbookTip: createWordbookTip, swipeActionTip: swipeActionTip)
                            .frame(minWidth: deviceType == .pad ? 400 : 300, minHeight: deviceType == .pad ? 400 : 300)
                            .presentationDetents([.large, .height(300)])
                            .overlay(alignment: .topTrailing) {
                                HStack {
                                    Spacer()
                                    Button {
                                        vm.showingSheet = false
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
                .navigationDestination(for: WordBook.self) { wordBook in
                    SavedWordsListView(wordBook: wordBook)
                }
                .navigationTitle(Localized.Word_Book)
                .toolbar {
                    
                    Button {
                        vm.showingSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .scaleEffect(1.2)
                    }
                    .tint(.red)
                    .popoverTip(createWordbookTip, arrowEdge: .top)
                }
            }
        }
        .onAppear {
            vm.fetchWordBookList(modelContext: modelContext)
            AnalyticsManager.shared.logEvent(name: "WordBookView_Appear")
        }
    }
}

extension WordBookView {
    private func changingWordBookSheetView(createWordbookTip: CreateWordBookTip, swipeActionTip: SwipeActionInWordBookTip) -> some View {
        VStack(alignment: .leading) {
            Text(vm.editingWordBook == nil ? Localized.Add_your_word_book_title : Localized.Update_your_word_book_title)
                .font(Font.custom("DIN Condensed", size: 25))
                .padding()
            TextField("", text: $vm.title, prompt: Text(Localized.Eg_Harry_Potter).foregroundColor(.white.opacity(0.7))).padding(6)
                .onChange(of: vm.title) { oldValue, newValue in
                    // Should validate textfield before submitting
                    vm.goodTitle = vm.validateTitle(title: newValue.trimmingCharacters(in: .whitespacesAndNewlines))
                    
                }
                .foregroundColor(.white)
                .submitLabel(.done)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color("SearchBar").opacity(0.35)))
                .padding(.horizontal)
                .presentationBackground(.thinMaterial)
                .presentationCornerRadius(15)
                .presentationDetents([.height(225)])
            
            // Promt text to indicate textfield error
            if vm.editingWordBook == nil {
                Text(vm.goodTitle ? "" : vm.message)
                    .font(Font.custom("DIN Condensed", size: 20))
                    .foregroundColor(.red)
                    .frame(height: 18)
                    .padding(.horizontal)
            } else {
                if let editingWordBook = vm.editingWordBook {
                    let filtered = vm.listWordBook.filter({$0.name != editingWordBook.name })
                    if filtered.contains(where: {$0.name == vm.title.trimmingCharacters(in: .whitespacesAndNewlines)}) {
                        Text(Localized.Sorry_This_title_is_already_taken)
                            .font(Font.custom("DIN Condensed", size: 20))
                            .foregroundColor(.red)
                            .frame(height: 18)
                            .padding(.horizontal)
                    }
                }
            }
            
            HStack {
                Spacer()
                Button {
                    vm.handleWordBook(wordBook: WordBook(name: vm.title), modelContext: modelContext)
                    createWordbookTip.invalidate(reason: .actionPerformed)
                    Task {
                        await SwipeActionInWordBookTip.swipeActionInWordBookEvent.donate()
                    }
                    vm.showingSheet = false
                } label: {
                    Text(vm.editingWordBook == nil ? Localized.Create : Localized.Update)
                        .foregroundColor(.white)
                        .frame(width: 100, height: 40)
                        .background(RoundedRectangle(cornerRadius: 5).fill(vm.goodTitle ? .orange.opacity(0.8) : .orange.opacity(0.2)))
                }
                .disabled(!vm.goodTitle)
            }
            .padding()
        }
        .onAppear {
            if let editingWordBook = vm.editingWordBook {
                vm.title = editingWordBook.name
            }
        }
        .onDisappear {
            vm.editingWordBook = nil
            vm.title = ""
            vm.message = ""
        }
        .padding()
    }
}

#Preview {
    WordBookView()
        .environmentObject(WordBookVM())
        .modelContainer(for: [Word.self, WordBook.self])
}
