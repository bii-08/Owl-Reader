//
//  BookwormApp.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/22.
//

import SwiftUI
import SwiftData
import GoogleMobileAds

class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    GADMobileAds.sharedInstance().start(completionHandler: nil)

    return true
  }
}

@main
struct BookwormApp: App {
    @AppStorage("isFirstTimeLaunch") private var isFirstTimeLaunch: Bool = true
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // defining the modelContainer
    let modelContainer: ModelContainer
      init() {
          
        do {
            modelContainer = try ModelContainer(for: Link.self, Shortcut.self, Headline.self, Word.self, WordBook.self)
            if isFirstTimeLaunch {
                Shortcut.defaults.forEach { modelContainer.mainContext.insert($0) }
                modelContainer.mainContext.insert(WordBook(name: "Default", isDefault: true))
                
                UserDefaults.standard.removeObject(forKey: "lastFetchDateForDefinition")
                print(UserDefaults.standard.string(forKey: "lastFetchDateForDefinition") as Any)
                print("This is the first launch")
                
                isFirstTimeLaunch = false
            }
        } catch {
          fatalError("Could not initialize ModelContainer")
        }
          // print the SQL file's path (SwiftData)
          print(URL.applicationSupportDirectory.path(percentEncoded: false))
//          UserDefaults.standard.removeObject(forKey: "isFirstTimeLaunch")  // For testing
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
