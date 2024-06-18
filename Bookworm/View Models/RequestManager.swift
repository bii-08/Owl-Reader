//
//  RequestManager.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/03.
//

import Foundation

@MainActor
class RequestManager: ObservableObject {
    static let shared: RequestManager = RequestManager()
    @Published var requestRemaning: Int {
        didSet {
            print("---> Request remaining: \(requestRemaning)")
        }
    }
    
    @Published var requestCount: Int {
        didSet {
            print("---> Request used: \(requestCount)")
        }
    }
    @Published var adsWatchCount: Int {
        didSet {
            print("---> adsWatchCount: \(adsWatchCount)")
            AnalyticsManager.shared.logEvent(name: "ads_watch_count_updated", params: ["adsWatchCount": adsWatchCount])
        }
    }
    var canMakeRequest: Bool {
        requestRemaning > 0
    }
    private let requestCountKey = "requestCount"
    private let requestRemaningKey = "requestRemaining"
    private let lastFetchDate = "lastFetchDateForDefinition"
    private let adsWatchCountKey = "adsWatchCount"
    init() {
        self.requestRemaning = UserDefaults.standard.integer(forKey: requestRemaningKey)
        self.requestCount = UserDefaults.standard.integer(forKey: requestCountKey)
        self.adsWatchCount = UserDefaults.standard.integer(forKey: adsWatchCountKey)
    }
    
    // FUNCTION: to reset requestCount and requestLimit if needed
    func resetCountIfNeeded() {
        let today = Date().formatted(date: .numeric, time: .omitted)
        let lastFetchDate = UserDefaults.standard.string(forKey: lastFetchDate)
        print("the last fetch date: \(String(describing: lastFetchDate))")
        if lastFetchDate != today || lastFetchDate == nil {
            UserDefaults.standard.set(0, forKey: requestCountKey)
            requestCount = 0
            UserDefaults.standard.set(25, forKey: requestRemaningKey) // 25
            requestRemaning = 25 // 25
            UserDefaults.standard.set(today, forKey: "lastFetchDateForDefinition")
            UserDefaults.standard.set(0, forKey: adsWatchCountKey)
            adsWatchCount = 0
        }
    }
    
    // FUNCTION: to calculate request count and request limit
    func calculateRequestCountAndRequestLimit() {
        requestCount += 1
        requestRemaning -= 1
        UserDefaults.standard.set(requestCount, forKey: requestCountKey)
        UserDefaults.standard.set(requestRemaning, forKey: requestRemaningKey)
    }
}
