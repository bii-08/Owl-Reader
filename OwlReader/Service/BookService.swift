//
//  BookService.swift
//  OwlReader
//
//  Created by LUU THANH TAM on 2024/07/08.
//

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class BookService: ObservableObject {
    @Published var dailystories: [Book] = [] {
        didSet {
           // print("---> daily stories data: \(dailystories)")
        }
    }
    @Published var sortOption: SortOption = .notSorted
    
    var sortedBooks: [Book] {
        switch sortOption {
        case .word:
            return dailystories.sorted(by: {$0.wordCount < $1.wordCount})
        case .grade:
            return dailystories.sorted(by: {$0.grade < $1.grade})
        case .notSorted:
            return dailystories
        }
    }
    
   
    
    func fetchDailyStories() {
        let db = Firestore.firestore()
        db.collection("dailyStories").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let querySnapshot = querySnapshot {
                    
                    // Update the dailystories property
                    DispatchQueue.main.async {
                        self.dailystories = querySnapshot.documents.map { doc in
                            return Book(title: doc["title"] as? String ?? "",
                                        author: doc["author"] as? String ?? "",
                                        wordCount: doc["wordCount"] as? Int ?? 0,
                                        genre: doc["genre"] as? String ?? nil,
                                        grade: doc["grade"] as? Int ?? 0,
                                        image: doc["image"] as? String ?? "",
                                        content: doc["content"] as? String ?? "",
                                        dateAdded: doc["dateAdded"] as? String ?? nil
                            )
                        }
                    }
                }
            }
        }
    }
    
    func notifyNewStory(story: Book) {
            // Logic to send local notification
            let content = UNMutableNotificationContent()
            content.title = "New Story Added!"
            content.body = "Check out the new story: \(story.title)"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request)
        }
    
}
