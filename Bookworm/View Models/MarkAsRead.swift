//
//  Favorites.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/13.
//

import SwiftUI

class MarkAsRead: ObservableObject {
    static let shared = MarkAsRead()
    @Published var shortStories: Set<String> = []
    private let key = "readStories"
    
    init() {
        load()
    }
    
    func contains(_ shortStory: Book) -> Bool {
        shortStories.contains(shortStory.title)
    }
    
    func add(_ shortStory: Book) {
        shortStories.insert(shortStory.title)
        print("-->\(shortStories)")
        save()
    }
    
    func remove(_ shortStory: Book) {
        shortStories.remove(shortStory.title)
        print("-->\(shortStories)")
        save()
    }
    
    func save() {
        if let encodedData = try? JSONEncoder().encode(shortStories) {
            UserDefaults.standard.set(encodedData, forKey: key)
        }
    }
    
    func load() {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let savedItems = try? JSONDecoder().decode(Set<String>.self, from: data)
        else { return }
        self.shortStories = savedItems
    }
}
