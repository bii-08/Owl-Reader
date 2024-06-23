//
//  ReviewRequestManager.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/17.
//

import Foundation
import SwiftData

final class ReviewRequestManager: ObservableObject {
    
    private let lastReviewedVersionKey = "lastReviewedVersion"
    private let lastReviewedDateKey = "lastReviewedDateKey"
    private let limit = 15
    
    func canAskForReview(numberOfWords: Int) -> Bool {
        // Check the recent reviewed version
        let mostRecentReviewed = UserDefaults.standard.string(forKey: lastReviewedVersionKey)
        print("--> mostRecentReviewedVersion: \(String(describing: mostRecentReviewed))")
        
        // Check the current version
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            fatalError("Could not find a bundle version in the info dictionary.")
        }
        print("--> currentVersion: \(String(describing: currentVersion))")
        
        // Check the date of today and the date of the last reviewed date
        let today = Date().formatted(date: .numeric, time: .omitted)
//        let today = "2024/05/18" // testing
        print("--> today: \(today)")
        let lastReviewedDate = UserDefaults.standard.string(forKey: lastReviewedDateKey)
        print("--> lastReviewedDate: \(String(describing: lastReviewedDate))")
        
        let hasReachLimit = numberOfWords.isMultiple(of: limit)
        let isNewVersion = currentVersion != mostRecentReviewed
        let numberOfDays = calculateDaysDifference() ?? 0
        
        if lastReviewedDate == nil {
            guard hasReachLimit && isNewVersion else {
                return false
            }
        } else {
            guard hasReachLimit && isNewVersion && numberOfDays > 21 else {
                return false
            }
        }
        
        UserDefaults.standard.set(currentVersion, forKey: lastReviewedVersionKey)
        UserDefaults.standard.set(today, forKey: lastReviewedDateKey)
        print("--> newlastReviewedDate: \(String(describing: UserDefaults.standard.string(forKey: lastReviewedDateKey)))")
        return true
    }
    
    func calculateDaysDifference() -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let todayString = Date().formatted(date: .numeric, time: .omitted)
        
        if let lastReviewedDateString = UserDefaults.standard.string(forKey: lastReviewedDateKey),
           let lastReviewedDate = dateFormatter.date(from: lastReviewedDateString),
           let today = dateFormatter.date(from: todayString) {
            let daysDifference = daysBetween(start: lastReviewedDate, end: today)
            print("--> daysDiff: \(daysDifference)")
                    return daysDifference
        }
        
        return nil
    }
    
    func daysBetween(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: start, to: end)
        return components.day ?? 0
    }
    
}
