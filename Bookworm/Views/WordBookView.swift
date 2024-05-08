//
//  WorkBookView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/05.
//

import SwiftUI

struct WordBookView: View {
    @EnvironmentObject var vm: WordBookVM
    
    @State private var addingWordBookTitle: String = ""
    
    var title: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color("background").ignoresSafeArea()
                VStack {
                    List {
                        ForEach(vm.listWordBook, id: \.self) { wordBook in
                            NavigationLink(value: wordBook) {
                                HStack {
                                    Text(wordBook.name)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    if let totalWordsNumber = wordBook.savedWords?.count {
                                        Text(totalWordsNumber == 0 ? "" : "\(totalWordsNumber)")
                                            .foregroundColor(.secondary)
                                    }
                                    
                                }
                            }
                            .listRowBackground(Color("background"))
                            .swipeActions(allowsFullSwipe: false) {
                                // Delete Button
                                Button(role: .destructive) {
                                    vm.deleteWordBook(wordBook: wordBook)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                                
                                // Edit Button
                                Button {
                                    vm.showingSheet = true
                                    vm.editingWordBook = wordBook
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.orange)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .sheet(isPresented: $vm.showingSheet) {
                        changingWordBookSheetView
                    }
                }
                .navigationDestination(for: WordBook.self) { wordBook in
                    SavedWordsListView(wordBook: wordBook)
                }
                .navigationTitle("Word Book")
                .toolbar {
                    Button {
                        vm.showingSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .scaleEffect(1.2)
                        
                    }
                    .tint(.red)
                }
                
            }
            
        }
        
    }
}

extension WordBookView {
    private var changingWordBookSheetView: some View {
        VStack(alignment: .leading) {
            Text(vm.editingWordBook == nil ? "Add your word book title" : "Update your word book title")
                .font(Font.custom("DIN Condensed", size: 25))
                .padding()
            TextField("", text: $vm.title, prompt: Text("Eg. Harry Potter").foregroundColor(.white.opacity(0.7))).padding(6)
                .onChange(of: vm.title) { oldValue, newValue in
                  // should validate textfield before submitting
                        vm.goodTitle = vm.validateTitle(title: newValue)
                    
                }
                .foregroundColor(.white)
                .submitLabel(.done)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color("SearchBar").opacity(0.35)))
                .padding(.horizontal)
                .presentationBackground(.thinMaterial)
                .presentationCornerRadius(15)
                .presentationDetents([.height(200)])
            
//            Text(vm.message)
//                .font(Font.custom("DIN Condensed", size: 20))
//                .foregroundColor(.red)
//                .padding(.horizontal)
                
            
            HStack {
                Spacer()
                Button {
                    vm.handleWordBook(wordBook: WordBook(name: vm.title))
                    vm.showingSheet = false
                    
                } label: {
                    Text(vm.editingWordBook == nil ? "Create" : "Update")
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
        }
        .padding()
    }
}


#Preview {
    WordBookView()
        .environmentObject(WordBookVM())
}
