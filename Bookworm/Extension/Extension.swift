//
//  Extension.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/30.
//

import Foundation
import SwiftUI
import NaturalLanguage
// Extension to parse JSON
extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy

        do {
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError("Failed to decode \(file) from bundle due to type mismatch – \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing \(type) value – \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Failed to decode \(file) from bundle because it appears to be invalid JSON")
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
    }
}



extension View {
    // Extension of View for onLoad Modifier
    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(OnLoadModifier(perform: action))
    }
}

extension String {
    func lemmatize() -> String {
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = self
       
//        let range = NSRange(location: 0, length: word.utf16.count)
//        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]
        var result = ""
        tagger.enumerateTags(in: self.startIndex..<self.endIndex, unit: .word, scheme: .lemma) { tag, range in
           let stemForm = tag?.rawValue ?? String(self[range])
            result = stemForm
            return true
        }
        return result
    }
    
    func truncatedText() -> String {
        if self.count > 12 {
            return String(self.prefix(12)) + "..."
        } else {
            return self
        }
    }
}



struct OnLoadModifier: ViewModifier {
    @State private var didLoad = false
    private let action: (() -> Void)?
    
    public init(perform action: (() -> Void)? = nil) {
        self.action = action
    }
    
    public func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action?()
            }
        }
    }
}
