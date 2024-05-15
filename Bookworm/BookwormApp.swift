//
//  BookwormApp.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/22.
//

import SwiftUI
import SwiftData

@main
struct BookwormApp: App {
    // defining the modelContainer
    let modelContainer: ModelContainer
      init() {
        do {
            modelContainer = try ModelContainer(for: Link.self, Headline.self, Word.self, WordBook.self)
        } catch {
          fatalError("Could not initialize ModelContainer")
        }
          // print the SQL file's path (SwiftData)
          print(URL.applicationSupportDirectory.path(percentEncoded: false))
      }
    
    var body: some Scene {
        WindowGroup {
            TabBar()
                .environmentObject(HomeVM())
                .environmentObject(WordBookVM())
        }
        .modelContainer(modelContainer)
    }
}
