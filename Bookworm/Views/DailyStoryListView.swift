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
    var body: some View {
        NavigationStack {
                List {
                    ForEach(books, id: \.self) { book in
                        NavigationLink(value: book) {
                            BookRowView(book: book)
                        }
                        .listRowBackground(Color("headlineRounded"))
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color("background").edgesIgnoringSafeArea(.all))
                .navigationTitle(Localized.Daily_Story)
                .navigationDestination(for: Book.self) { book in
                    StoryReadingView(storyReadingVM: StoryReadingVM(book: book), showingDefinition: $showingDefinition)
                }
        }
        .onAppear {
            AnalyticsManager.shared.logEvent(name: "DailyStoryListView_Appear")
        }
        .onDisappear {
            AnalyticsManager.shared.logEvent(name: "DailyStoryListView_Disappear")
        }
    }
}

#Preview {
    DailyStoryListView()
}
