//
//  DailyStoryListView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/05.
//

import SwiftUI

struct DailyStoryListView: View {
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
                .navigationTitle("Daily Story")
                .navigationDestination(for: Book.self) { book in
                    StoryReadingView(storyReadingVM: StoryReadingVM(book: book))
                }
        }
    }
}

#Preview {
    DailyStoryListView()
}
