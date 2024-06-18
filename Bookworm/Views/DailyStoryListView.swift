//
//  DailyStoryListView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/05.
//

import SwiftUI

struct DailyStoryListView: View {
    @State private var showingDefinition = false
    var books: [Book] = Book.defaults
    @State private var sortOption: SortOption = .notSorted
    var sortedBooks: [Book] {
        switch sortOption {
        case .word:
            return Book.defaults.sorted(by: {$0.wordCount < $1.wordCount})
        case .grade:
            return Book.defaults.sorted(by: {$0.grade < $1.grade})
        case .notSorted:
            return Book.defaults
        }
    }
    var body: some View {
        NavigationStack {
                
                List {
                    HStack {
                        Text(Localized.Daily_Story)
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.leading)
                           
                        Spacer()
                        
                        Picker("", selection: $sortOption) {
                            Text("Word Count").tag(SortOption.word)
                            Text("Difficulty").tag(SortOption.grade)
                        }
                        .pickerStyle(.menu)

                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
                    ForEach(sortedBooks, id: \.self) { book in
                        NavigationLink(value: book) {
                            BookRowView(book: book)
                        }
                        .listRowBackground(Color("headlineRounded"))
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color("background").edgesIgnoringSafeArea(.all))
                .navigationBarHidden(true)
                //                .navigationTitle(Localized.Daily_Story)
                .navigationDestination(for: Book.self) { book in
                    StoryReadingView(storyReadingVM: StoryReadingVM(book: book), showingDefinition: $showingDefinition)
                }
                
//            }
        }
        .onAppear {
            AnalyticsManager.shared.logEvent(name: "DailyStoryListView_Appear")
            sortOption = .notSorted
        }
        .onDisappear {
            AnalyticsManager.shared.logEvent(name: "DailyStoryListView_Disappear")
        }
    }
}

#Preview {
    DailyStoryListView()
}
