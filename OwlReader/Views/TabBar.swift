//
//  TabView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/06.
//

import SwiftUI
import SwiftData

struct TabBar: View {
    @EnvironmentObject var vm: HomeVM
    @State private var flashcardOff = true
    @ObservedObject var navigationManager = NavigationManager.shared
    var body: some View {
        
        TabView(selection: $navigationManager.selectedTab) {
            HomeView()
                .tabItem {
                    Label(Localized.Home, systemImage: "house")
                }
                .tag(0)
                
            WordBookView()
                .tabItem {
                    Label(Localized.Word_Book, systemImage: "book.pages")
                }
                .tag(1)
            
            DailyStoryListView()
                .tabItem {
                    Label(Localized.Daily_story, systemImage: "book.fill")
                }
                .tag(2)
            NavigationStack {
                AllWordsView()
            }
            .tabItem {
                Label(Localized.All_words, systemImage: "heart")
            }
            .tag(3)
            
            if !flashcardOff {
                ReviewingWordView()
                    .tabItem {
                        Label("Flashcard", systemImage: "lanyardcard.fill")
                    }
                    .tag(4)
            }
        }
        .accentColor(.tabBarButton)
    }
}

#Preview {
    TabBar()
        .environmentObject(HomeVM())
        .environmentObject(WordBookVM())
        .modelContainer(for: [Link.self, Shortcut.self, Headline.self, Word.self, WordBook.self])
}
