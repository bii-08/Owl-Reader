//
//  WorkBookView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/05.
//

import SwiftUI

struct WordBookView: View {
    @EnvironmentObject var vm: WordBookVM
    var body: some View {
        NavigationStack {
            ZStack {
                Color("background").ignoresSafeArea()
                VStack {
                    List {
                        ForEach(vm.listWordBook, id: \.self) { wordBook in
                            NavigationLink(wordBook.name, value: wordBook)
                                .foregroundColor(.secondary)
                                .listRowBackground(Color("background"))
                        }
                    }
                    .listStyle(.plain)
                }
                .navigationDestination(for: WordBook.self) { wordBook in
                    SavedWordsListView(wordBook: wordBook)
                }
                .navigationTitle("Word Book")
                .toolbar { 
                    Button {
                        
                    } label: {
                        Image(systemName: "Plus")
                    }
                }
                
            }
            
        }
        
    }
}

#Preview {
        WordBookView()
        .environmentObject(WordBookVM())
}
