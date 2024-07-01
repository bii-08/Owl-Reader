//
//  HeadlinesService.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/30.
//

import Foundation
import SwiftyJSON

enum NetworkError: Error {
    case badRequest
    case badResponse
    case badStatus
    case badURL
    case decodingError
    case failedToDecodeResponse
}
protocol WebServiceDelegate {
    func downloadData<T: Codable>(fromURL: String) async -> T?
    func downloadWord<T: Codable>(word: String) async -> T?
}

// For downloading data from the Internet
class WebService: WebServiceDelegate {
    func downloadData<T: Codable>(fromURL: String) async -> T? {
        do {
            guard let url = URL(string: fromURL) else { throw NetworkError.badURL }
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse else { throw NetworkError.badResponse }
            guard response.statusCode >= 200 && response.statusCode < 300 else { throw NetworkError.badStatus }
            print(response)
            
            guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else { throw NetworkError.failedToDecodeResponse }
            
            return decodedResponse
        } catch NetworkError.badURL {
            print("There was an error creating the URL")
        } catch NetworkError.badResponse {
            print("Did not get a valid response")
        } catch NetworkError.badStatus {
            print("Did not get a 2xx status code from the response")
        } catch NetworkError.failedToDecodeResponse {
            print("Failed to decode response into the given type")
        } catch {
            print("An error occured downloading the data")
        }
        return nil
    }
    
    func downloadWord<T: Codable>(word: String) async -> T? {
        do {
            guard let apiKey = Bundle.main.infoDictionary?["X_RapidAPI_Key"] as? String else { return nil }
            guard let host = Bundle.main.infoDictionary?["X_RapidAPI_Host"] as? String else { return nil }
        // Define the headers for the request
        let headers = [
            "X-RapidAPI-Key": "\(apiKey)",
            "X-RapidAPI-Host": "\(host)"
        ]
        // Define the URL for the request
        let url = "https://\(host)/words/\(word)"
        guard let url = URL(string: url) else { throw NetworkError.badURL }
        // Create a URL request and set its properties
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
            
        request.allHTTPHeaderFields = headers
        
            // Perform the data task using async/await
            let (data, response) = try await URLSession.shared.data(for: request)
            print(JSON(data))
            // Check the response status code (optional)
            guard let httpResponse = response as? HTTPURLResponse  else { throw NetworkError.badResponse }
            print(httpResponse)
            guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else { throw NetworkError.failedToDecodeResponse }
            return decodedResponse

        } catch NetworkError.badURL {
            print("There was an error creating the URL")
        } catch NetworkError.badResponse {
            print("Did not get a valid response")
        } catch NetworkError.badStatus {
            print("Did not get a 2xx status code from the response")
        } catch NetworkError.failedToDecodeResponse {
            print("Failed to decode response into the given type")
        } catch {
            print("An error occured downloading the data")
        }
        return nil
    }
}
