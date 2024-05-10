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
    @Published var recentlyReadURLs: [String] = []
    @Published var headLines: [Headline] = [Headline(title: "BBC Gaza reporter: My struggle to keep family safe while covering the war", url: "https://www.bbc.co.uk/news/world-middle-east-68906903", urlToImage: "https://ichef.bbci.co.uk/news/1024/branded_news/977D/production/_133218783_razan_hug.jpg"), Headline(title: "BBC Gaza reporter: My struggle to keep family safe while covering the war", url: "https://www.bbc.co.uk/news/world-middle-east-68906903", urlToImage: "https://ichef.bbci.co.uk/news/1024/branded_news/977D/production/_133218783_razan_hug.jpg"), Headline(title: "BBC Gaza reporter: My struggle to keep family safe while covering the war", url: "https://www.bbc.co.uk/news/world-middle-east-68906903", urlToImage: "https://ichef.bbci.co.uk/news/1024/branded_news/977D/production/_133218783_razan_hug.jpg")]
    
    var isValidURL = false
    var isUrlAlreadyExists = false
    var isTitleValid = false
    var isTitleAlreadyExists = false
    
    
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
        
        do {
            // Create a regular expression instance
            let regex = try NSRegularExpression(pattern: urlPattern)
            
            // Check if the URL string matches the pattern
            let range = NSRange(urlString.startIndex..., in: urlString)
            let matches = regex.numberOfMatches(in: urlString, options: [], range: range)
            
            // Return true if there is at least one match, otherwise false
            return matches > 0
        } catch {
            // If an error occurs while creating the regular expression, return false
            print("Invalid URL. Error creating regular expression: \(error)")
            return false
        }
    }
    
    func isUrlAlreadyExists(urlString: String, stored: [Link]) -> Bool {
        // Normalize the user-entered URL
        let normalizedUserURL = normalizeURL(urlString)
        guard !stored.contains(where: { $0.url.absoluteString == normalizedUserURL }) else {
            print("This URL is already exists.")
            return true
        }
        return false
    }
    
    static func isTitleValid(title: String) -> Bool {
        guard !title.isEmpty else {
            print("The title is empty.")
            return false
        }
        
        // Trim the title to remove leading and trailing spaces
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Ensure the title does not contain only spaces after trimming
        guard !trimmedTitle.isEmpty else {
            print("The trimmed title is empty.")
            return false
        }
        
        // Ensure the title contains only letters, numbers, and spaces
        let validCharacterSet = CharacterSet.alphanumerics.union(CharacterSet.whitespaces)
        guard trimmedTitle.rangeOfCharacter(from: validCharacterSet.inverted) == nil else {
            print("The title should only contains letters, numbers and spaces.")
            return false
        }
        
        // Ensure the length of the title is between 3 and 20 characters
        guard trimmedTitle.count >= 3 && trimmedTitle.count <= 20 else {
            print("The length of the title should be between 3 and 20 characters.")
            return false
        }
        // Return true if all conditions are met
        return true
    }
    
    func isTitleAlreadyExists(title: String, stored: [Link]) -> Bool {
        guard !stored.contains(where: { $0.webPageTitle == title}) else {
            print("This title is already exists.")
            return true
        }
        return false
    }
    
    func addLink(newLink: Link) {
        savedShortcuts.append(newLink)
    }
    
    func updateLink(linkNeedToUpdate: Link, newLink: Link) {
        if let index = savedShortcuts.firstIndex(where: { $0.id == linkNeedToUpdate.id }) {
            savedShortcuts[index] = newLink
        }
    }
    
    func normalizeURL(_ urlString: String) -> String {
        var normalizedURL = urlString.lowercased()
        
        // Remove any trailing slashes
        normalizedURL = normalizedURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        // Return the normalized URL
        return normalizedURL
    }
    
    // FUNCTION: to add URL into recentlyReadURLs array
    func addURL(urlString: String) {
        // if the URL already exists in the list
        if recentlyReadURLs.contains(urlString) {
            if let index = recentlyReadURLs.firstIndex(of: urlString) {
                recentlyReadURLs.remove(at: index)
            }
        }
        // Add the URL to the top of the list
        recentlyReadURLs.insert(urlString, at: 0)
        
        
        if recentlyReadURLs.count > 10 {
            recentlyReadURLs = Array(recentlyReadURLs.prefix(10))
        }

        saveRecentlyReadURLs()
    }
    
    // Save the list of recently read URLs to UserDefaults
    private func saveRecentlyReadURLs() {
        UserDefaults.standard.set(recentlyReadURLs, forKey: "recentlyReadURLs")
    }
    
    // Load the list of recently read URLs from UserDefaults
    private func loadRecentlyReadURLs() {
        if let savedURLs = UserDefaults.standard.array(forKey: "recentlyReadURLs") as? [String] {
            recentlyReadURLs = savedURLs
        }
    }
        // FUNCTION: for fetching data from real api
        func fetchHeadlines() async {
            headLines = [Headline]()
            if let downloadedHeadlines: HeadlinesResultReponse = await webService.downloadData(fromURL: "https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey=c0054895dda142d5896f81665100a207&pageSize=10") {
                headLines = downloadedHeadlines.articles
            }
        }
    }
    
