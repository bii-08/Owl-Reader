//
//  RequestManager.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/03.
//

import Foundation

class RequestManager: ObservableObject {
    static let shared: RequestManager = RequestManager()
    @Published var requestRemaning: Int {
        didSet {
            print("---> Request remaining: \(requestRemaning)")
        }
    }
    
    @Published var requestCount: Int {
        didSet {
            print("---> Request remaining: \(requestCount)")
        }
    }
    var canMakeRequest: Bool {
        requestRemaning > 0
    }
    private let requestCountKey = "requestCount"
    private let requestRemaningKey = "requestRemaining"
    init(requestRemaning: Int = 0, requestCount: Int = 0) {
        self.requestRemaning = UserDefaults.standard.integer(forKey: requestRemaningKey)
        self.requestCount = UserDefaults.standard.integer(forKey: requestCountKey)
    }
}
