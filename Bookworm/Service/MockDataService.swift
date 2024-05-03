//
//  MockDataHeadlinesService.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/30.
//

import Foundation

// Mockdata for testing Headlines
class MocdataWebService: WebServiceDelegate {
    func downloadData<T: Codable>(fromURL: String) async -> T? {
        let mockHeadlines = Bundle.main.decode(HeadlinesResultReponse.self, from: "Headlines.json")
        return mockHeadlines as? T
    }
}

class MockdataForWord: WebServiceDelegate {
    func downloadData<T: Codable>(fromURL: String) async -> T? {
        let mockWord = Bundle.main.decode(Word.self, from: "Word.json")
        return mockWord as? T
    }
}
