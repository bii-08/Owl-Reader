//
//  BookwormApp.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/22.
//

import SwiftUI
import SwiftData
import GoogleMobileAds
import TipKit
import Firebase
import AdSupport
import AppTrackingTransparency
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    requestPermission()
    GADMobileAds.sharedInstance().start(completionHandler: nil)
    FirebaseApp.configure()
    return true
  }
     func requestPermission() {
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
             if #available(iOS 14, *) {
                 ATTrackingManager.requestTrackingAuthorization { status in
                     switch status {
                     case .authorized:
                         print("Authorized")
                         print(ASIdentifierManager.shared().advertisingIdentifier)
                     case .denied:
                         print("Denied")
                     case .notDetermined:
                         // Tracking authorization dialog has not been shown
                         print("Not Determined")
                     case .restricted:
                         print("Restricted")
                     @unknown default:
                         print("Unknown")
                     }
                 }
             }
         }
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
          
          // Purge all Tipkit related data.
//          try? Tips.resetDatastore()
          
          // Some some tips for testing(not all)
//          Tips.showTipsForTesting([SwipeActionInWordBookTip.self])
          
          // Hide some tips for testing(not all)
//          Tips.hideTipsForTesting([SwipeActionTip.self])
          
          // Show all defined tips in the app.
//          Tips.showAllTipsForTesting()
          
          // Hide all defined tips in the app.
//          Tips.hideAllTipsForTesting()
          
          try? Tips.configure()
      }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(HomeVM())
                .environmentObject(WordBookVM())
                .environmentObject(ReviewRequestManager())
        }
        .modelContainer(modelContainer)
    }
}
