//
//  NavigationManager.swift
//  OwlReader
//
//  Created by LUU THANH TAM on 2024/07/13.
//

import Foundation

class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    
    @Published var selectedTab: Int = 0
    @Published var shouldNavigateToDailyStory: Bool = false
}
