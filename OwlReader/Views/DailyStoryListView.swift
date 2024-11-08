//
//  DailyStoryListView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/05.
//

import SwiftUI

struct DailyStoryListView: View {
    @State private var showingDefinition = false
    @EnvironmentObject var bookService: BookService

    var body: some View {
        NavigationStack {
                List {
                    HStack {
                        Text(Localized.Daily_Story)
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.leading)
                           
                        Spacer()
                        
                        Picker("", selection: $bookService.sortOption) {
                            Text("Word Count").tag(SortOption.word)
                            Text("Difficulty").tag(SortOption.grade)
                        }
                        .pickerStyle(.menu)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
                    ForEach(bookService.sortedBooks, id: \.self) { book in
                        NavigationLink(value: book) {
                            BookRowView(book: book)
                        }
                        .listRowBackground(Color("headlineRounded"))
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color("background").edgesIgnoringSafeArea(.all))
                .navigationBarHidden(true)
                .navigationDestination(for: Book.self) { book in
                    StoryReadingView(storyReadingVM: StoryReadingVM(book: book), showingDefinition: $showingDefinition)
                }
        }
        .onAppear {
            AnalyticsManager.shared.logEvent(name: "DailyStoryListView_Appear")
            bookService.sortOption = .notSorted
        }
        .onDisappear {
            AnalyticsManager.shared.logEvent(name: "DailyStoryListView_Disappear")
        }
    }
}

#Preview {
    DailyStoryListView()
}
