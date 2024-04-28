//
//  HomeVM.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/24.
//

import Foundation
class HomeVM: ObservableObject {
    
    @Published var savedShortcuts: [Link]
    @Published var recentlyRead: [Link] = []
    @Published var isValidURL = false
    
    init() {
        savedShortcuts = [Link(url: URL(string: "https://www.investopedia.com/")!, favicon: URL(string: "https://www.investopedia.com/favicon.ico/")!, webPageTitle: "Investopidea"),
                             Link(url: URL(string: "https://www.apple.com/")!, favicon: URL(string: "https://www.apple.com/favicon.ico")!, webPageTitle: "Apple"), Link(url: URL(string: "https://www.bbc.com/")!, favicon: URL(string: "https://www.bbc.com/favicon.ico")!, webPageTitle: "BBC News")]
    }
    
    func validateURL(urlString: String) {
//        if let _ = URL(string: urlString) {
//            isValidURL = true
//        } else {
//            isValidURL = false
//        }
    }
    
    func addLink(newLink: Link) {
      
            savedShortcuts.append(newLink)
        
    }
    
    
}

