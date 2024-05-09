//
//  TabView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/06.
//

import SwiftUI

struct TabBar: View {
    @EnvironmentObject var vm: HomeVM
    var body: some View {
        
        TabView { 
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
                
            WordBookView()
                .tabItem {
                    Label("Word Book", systemImage: "book.pages")
                }
                .tag(1)
        }
        .accentColor(.tabBarButton)
    }
}

#Preview {
    TabBar()
        .environmentObject(HomeVM())
        .environmentObject(WordBookVM())
}
