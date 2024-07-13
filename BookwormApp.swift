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
import FirebaseMessaging

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

  func application(_ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    GADMobileAds.sharedInstance().start(completionHandler: nil)
      
    UNUserNotificationCenter.current().delegate = self
    requestNotificationPermissions() // For notification
    requestPermission() // For tracking
    application.registerForRemoteNotifications()
      
    Messaging.messaging().delegate = self
      
    return true
  }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(deviceToken)
            Messaging.messaging().apnsToken = deviceToken
        }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("--Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcm = Messaging.messaging().fcmToken {
            print("--FCM Token: \(fcm)")
        } else {
            print("--Failed to get FCM token")
        }
    }

        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.banner, .list, .badge, .sound])
        }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("--User info: \(userInfo)")
        DispatchQueue.main.async {
            NavigationManager.shared.selectedTab = 2
        }
        completionHandler()
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
    
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notifications permissions: \(error.localizedDescription)")
            } else if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}

@main
struct BookwormApp: App {
    @AppStorage("isFirstTimeLaunch") private var isFirstTimeLaunch: Bool = true
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var bookService = BookService()
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
//          requestNotificationPermissions()
      }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(HomeVM())
                .environmentObject(WordBookVM())
                .environmentObject(ReviewRequestManager())
                .environmentObject(bookService)
                .onAppear {
                    DispatchQueue.main.async {
                        bookService.fetchDailyStories()
                    }
                }
        }
        .modelContainer(modelContainer)
    }
}
