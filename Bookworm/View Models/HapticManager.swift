//
//  HapticManager.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/14.
//

import SwiftUI

class HapticManager {
    static let shared = HapticManager()
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
