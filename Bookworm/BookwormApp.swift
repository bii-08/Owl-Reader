//
//  BookwormApp.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/22.
//

import SwiftUI

@main
struct BookwormApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(HomeVM())
        }
    }
}
