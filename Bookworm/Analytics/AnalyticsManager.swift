//
//  AnalyticsManager.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/12.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {}
    
    func logEvent(name: String, params: [String:Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
    }
}


