//
//  MockDataHeadlinesService.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/30.
//

import Foundation

// Mockdata for testing
class MocdataWebService: WebServiceDelegate {
    func downloadHeadlines<T: Codable>(fromURL: String) async -> T? {
        
        let mockHeadlines = Bundle.main.decode(HeadlinesResultReponse.self, from: "Headlines.json")
        return mockHeadlines as? T
    }
}
