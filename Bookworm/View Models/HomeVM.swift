//
//  HomeVM.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/24.
//

import Foundation
import SwiftUI

class HomeVM: ObservableObject {
    private let webService: WebServiceDelegate
    @Published var savedShortcuts: [Link]
    @Published var recentlyRead: [Link] = []
    @Published var headLines: [Headline] = [Headline(title: "BBC Gaza reporter: My struggle to keep family safe while covering the war", url: "https://www.bbc.co.uk/news/world-middle-east-68906903", urlToImage: "https://ichef.bbci.co.uk/news/1024/branded_news/977D/production/_133218783_razan_hug.jpg"), Headline(title: "BBC Gaza reporter: My struggle to keep family safe while covering the war", url: "https://www.bbc.co.uk/news/world-middle-east-68906903", urlToImage: "https://ichef.bbci.co.uk/news/1024/branded_news/977D/production/_133218783_razan_hug.jpg"), Headline(title: "BBC Gaza reporter: My struggle to keep family safe while covering the war", url: "https://www.bbc.co.uk/news/world-middle-east-68906903", urlToImage: "https://ichef.bbci.co.uk/news/1024/branded_news/977D/production/_133218783_razan_hug.jpg")]
    
    var isValidURL = false
    var isUrlAlreadyExists = false
    var isTitleValid = false
    var isTitleAlreadyExists = false
    
    @Published var message = ""
    
    @Published var showingAlert = false
    @Published var showingEditingView = false
    init(webService: WebServiceDelegate = MocdataWebService()) {
        self.webService = webService
        savedShortcuts = [Link(url: URL(string: "https://www.investopedia.com")!, favicon: UIImage(named: "investopedia"), webPageTitle: "Investopideaaaaaaaaaaa"),
                             Link(url: URL(string: "https://www.apple.com")!, favicon: UIImage(named: "apple"), webPageTitle: "Apple"), Link(url: URL(string: "https://www.bbc.com")!, favicon: UIImage(named: "BBC news"), webPageTitle: "BBC News")]
        Task {
            await fetchHeadlines()
        }
    }
    
    func validateURL(urlString: String) -> Bool {
        // Define a regular expression pattern for a valid URL
            let urlPattern = "^(https?://)?(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,}(?:/\\S*)?$"
            
            // Create a regular expression instance
            let regex = try? NSRegularExpression(pattern: urlPattern)
            
            // Check if the URL string matches the pattern
            let range = NSRange(urlString.startIndex..., in: urlString)
            let matches = regex?.matches(in: urlString, options: [], range: range)
            
            // If there is at least one match, the URL is valid
            return matches?.count ?? 0 > 0
    }
    
    func isUrlAlreadyExists(urlString: String) -> Bool {
        // Normalize the user-entered URL
        let normalizedUserURL = normalizeURL(urlString)
        if savedShortcuts.contains(where: { $0.url.absoluteString == normalizedUserURL }) {
            return true
        }
        return false
    }
    
   static func isTitleValid(title: String) -> Bool {
        guard !title.isEmpty else { return false }
        
        // Trim the title to remove leading and trailing spaces
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Ensure the title does not contain only spaces after trimming
        guard !trimmedTitle.isEmpty else { return false }
        
        // Ensure the title contains only letters, numbers, and spaces
        let validCharacterSet = CharacterSet.alphanumerics.union(CharacterSet.whitespaces)
        guard trimmedTitle.rangeOfCharacter(from: validCharacterSet.inverted) == nil else { return false }
        
        // Ensure the length of the title is between 3 and 20 characters
        guard trimmedTitle.count >= 3 && trimmedTitle.count <= 20 else { return false }
        // Return true if all conditions are met
        return true
    }
    
    
    func addLink(newLink: Link) {
        savedShortcuts.append(newLink)
    }
    
    func updateLink(link: Link) {
        if let index = savedShortcuts.firstIndex(where: { $0.url == link.url }) {
            savedShortcuts[index].url = link.url
            savedShortcuts[index].webPageTitle = link.webPageTitle
            savedShortcuts[index].favicon = link.favicon
        }
    }
    
    func isEditingInputValid(link: Link) -> Bool {
        
        // Ensure the title is valid
        guard HomeVM.isTitleValid(title: link.webPageTitle) else {
            print("the title is invalid.")
            return false
        }
        // Ensure the title is unique
        guard !savedShortcuts.contains(where: { $0.webPageTitle == link.webPageTitle }) else {
            print("the url is already exists.")
            return false
        }
        // Ensure the URL is valid
        guard validateURL(urlString: link.url.absoluteString) else {
            print("the url is invalid.")
            return false
        }
        // Ensure the URL is unique
        guard isUrlAlreadyExists(urlString: link.url.absoluteString) else {
            print("the url is already exists.")
            return false
        }
        
        return true
    }
    
    
    func normalizeURL(_ urlString: String) -> String {
        var normalizedURL = urlString.lowercased()
        
        // Remove any trailing slashes
        normalizedURL = normalizedURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        // Return the normalized URL
        return normalizedURL
    }
    
    // FUNCTION: for fetching data from real api
        func fetchHeadlines() async {
        headLines = [Headline]()
            if let downloadedHeadlines: HeadlinesResultReponse = await webService.downloadData(fromURL: "https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey=c0054895dda142d5896f81665100a207&pageSize=10") {
                headLines = downloadedHeadlines.articles
            }
        }
}


