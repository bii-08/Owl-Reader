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
    @Published var showingAlert = false
    @Published var showingEditingView = false
    init(webService: WebServiceDelegate = MocdataWebService()) {
        self.webService = webService
        savedShortcuts = [Link(url: URL(string: "https://www.investopedia.com")!, favicon: UIImage(named: "investopedia"), webPageTitle: "Investopidea"),
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
        return savedShortcuts.contains { $0.url.absoluteString == urlString || $0.url.absoluteString == urlString + "/" }
    }
    
    func isTitleValid(title: String) -> Bool {
            let alphanumericCharacterSet = CharacterSet.alphanumerics
            return !title.isEmpty &&
               title.rangeOfCharacter(from: alphanumericCharacterSet.inverted) == nil &&
          title.count <= 20 && title.count >= 3
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
    
    // FUNCTION: for fetching data from real api
        func fetchHeadlines() async {
        headLines = [Headline]()
            if let downloadedHeadlines: HeadlinesResultReponse = await webService.downloadData(fromURL: "https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey=c0054895dda142d5896f81665100a207&pageSize=10") {
                headLines = downloadedHeadlines.articles
            }
        }
    
    
    
}

