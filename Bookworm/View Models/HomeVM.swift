//
//  HomeVM.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/24.
//

import Foundation
import SwiftUI
import SwiftData

class HomeVM: ObservableObject {
    private let webService: WebServiceDelegate
    @Published var savedShortcuts: [Shortcut] = []
    @Published var recentlyReadURLs: [Link] = []
    @Published var headLines: [Headline] = []
    
    var isValidURL = false
    var isUrlAlreadyExists = false
    var isTitleValid = false
    var isTitleAlreadyExists = false
    
    var loadingState = LoadingStateManager.loading
    let locale = Locale.current
    @Published var showingAlert = false
    @Published var showingEditingView = false
    var testing = false // true: api, false: database
    
    // NOTE: Replace MockdataWebService() with WebService() to fetch headlines data from real API
    init(webService: WebServiceDelegate = MockdataWebService()) {
        self.webService = webService
        print(Date.distantPast)
        print(Locale.current.region?.identifier ?? "")
        print("--> \(Bundle.main.preferredLocalizations.first as Any)")
    }
    
    // FUNCTION: to validate the given URL
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
    
    // FUNCTION: to check if the given URL is already exists on the shortcut list or not
    func isUrlAlreadyExists(urlString: String, stored: [Shortcut]) -> Bool {
        // Normalize the user-entered URL
        let normalizedUserURL = normalizeURL(urlString)
        guard !stored.contains(where: { $0.url.absoluteString == normalizedUserURL }) else {
            print("This URL is already exists.")
            return true
        }
        return false
    }
    
    // FUNCTION: to check if the webpage's title is valid or not
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
        guard trimmedTitle.count >= 2 && trimmedTitle.count <= 20 else {
            print("The length of the title should be between 3 and 20 characters.")
            return false
        }
        // Return true if all conditions are met
        return true
    }
    
    // FUNCTION: to check if the given webpage's title is already exists or not
    func isTitleAlreadyExists(title: String, stored: [Shortcut]) -> Bool {
        guard !stored.contains(where: { $0.webPageTitle == title}) else {
            print("This title is already exists.")
            return true
        }
        return false
    }
    
    // FUNCTION: to add link(url) to the shortcut list
    func addLink(newShortcut: Shortcut, modelContext: ModelContext) {
        modelContext.insert(newShortcut)
    }
    
    // FUNCTION: to normalize the given URL (Eg: if the given url is sth like https://www.apple.com/ -> normalize it to https://www.apple.com
    func normalizeURL(_ urlString: String) -> String {
        var normalizedURL = urlString.lowercased()
        
        // Remove any trailing slashes
        normalizedURL = normalizedURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        // Return the normalized URL
        return normalizedURL
    }
    
    
    // FUNCTION: to add URL into recentlyReadURLs array
    func addURL(link: Link?, modelContext: ModelContext) {
        // if the URL already exists in the list
        if recentlyReadURLs.contains(where: { $0.url == link?.url }) {
            if let index = recentlyReadURLs.firstIndex(where: { $0.url == link?.url }) {
                modelContext.delete(recentlyReadURLs[index])
            }
        }
        // Add the URL to the top of the list
        if let link {
            modelContext.insert(link)
        }
        
        if recentlyReadURLs.count > 10 {
            recentlyReadURLs = Array(recentlyReadURLs.prefix(10))
        }
        
        fetchRecentlyReadURLs(modelContext: modelContext)
    }
    
    func handleUserInputSearchBar(userInput: String) -> String {
        if let url = URL(string: userInput), UIApplication.shared.canOpenURL(url) {
            return userInput
        } else {
            let searchQuery = userInput.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "https://www.google.com/search?q=\(searchQuery)"
        }
    }
    
    // FUNCTION: for fetching data from real api
    @MainActor func fetchHeadlinesFromAPI(modelContext: ModelContext) async {
        headLines = [Headline]()
        guard let apiKey = Bundle.main.infoDictionary?["HEADLINE_API_KEY"] as? String else { return }
        if let downloadedHeadlines: HeadlinesResultReponse = await webService.downloadData(fromURL: "https://newsapi.org/v2/everything?domains=techcrunch.com,newyorker.com,bbc.com,nypost.com&apiKey=\(apiKey)&pageSize=25&language=en") {
            headLines = downloadedHeadlines.articles
            headLines.forEach{ modelContext.insert($0) }
            
            loadingState = LoadingStateManager.success
            print("------> Successfully fetched headlines data from api.")
        } else {
            loadingState = LoadingStateManager.failed
            print("Failed to load headlines!")
        }
    }
    
    @MainActor func fetchHeadlinesFromDataBase(modelContext: ModelContext) {
        do {
            let descriptor = FetchDescriptor<Headline>(sortBy: [])
            headLines = try modelContext.fetch(descriptor)
            loadingState = LoadingStateManager.success
            print("------> Successfully fetched headlines from database.")
        } catch {
            loadingState = LoadingStateManager.failed
            print("Failed to fetch headlines from database.")
        }
    }
    
    // FUNCTION: to fetch shortcut list from model context.
    func fetchShortcuts(modelContext: ModelContext) {
        do {
            let descriptor = FetchDescriptor<Shortcut>(sortBy: [])
            savedShortcuts = try modelContext.fetch(descriptor)
        } catch {
            print("Fetch shortcut list failed")
        }
    }
    
    // FUNCTION: to fetch saved wordBook list from model context.
    func fetchRecentlyReadURLs(modelContext: ModelContext) {
        do {
            let descriptor = FetchDescriptor<Link>(sortBy: [])
            recentlyReadURLs = try modelContext.fetch(descriptor)
        } catch {
            print("Fetch Recently Read data failed")
        }
    }
    
    @MainActor func handleHeadlines(modelContext: ModelContext) async {
        let today = Date().formatted(date: .numeric, time: .omitted)
        print("---> \(today)")
        let lastFetchDate = UserDefaults.standard.string(forKey: "lastFetchDate")
        print("---> \(String(describing: lastFetchDate))")
        
        if today != lastFetchDate {
            do {
               try modelContext.delete(model: Headline.self)
                UserDefaults.standard.set(today, forKey: "lastFetchDate")
            } catch {
                print("Failed to delete all headlines.")
            }
           
            await fetchHeadlinesFromAPI(modelContext: modelContext)

        } else {
            fetchHeadlinesFromDataBase(modelContext: modelContext)
        }
    }
}
