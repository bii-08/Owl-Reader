//
//  MockDataHeadlinesService.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/30.
//

import Foundation

// Mockdata for testing Headlines
class MockdataWebService: WebServiceDelegate {
    func downloadData<T: Codable>(fromURL: String) async -> T? {
        let mockHeadlines = Bundle.main.decode(HeadlinesResultReponse.self, from: "Headlines.json")
        return mockHeadlines as? T
    }
}

// Mocdata for testing Word (mainly building UI for Definition View)
class MockdataForWord: DictionaryServiceDelegate {
    func downloadWord<T: Codable>(word: String) async -> T?{
        let mockWord = Bundle.main.decode(Word.self, from: "Word.json")
        return mockWord as? T
    }
}
