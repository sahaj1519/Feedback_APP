//
//  Bundle-Decodable.swift
//  Feedback App
//
//  Created by Ajay Sangwan on 29/03/25.
//

import Foundation

extension Bundle {
    /// Decodes a JSON file from the app bundle into a Swift `Decodable` type.
    ///
    /// This function simplifies loading and decoding JSON files bundled within the app.
    ///
    /// - Parameters:
    ///   - file: The name of the JSON file, including its extension.
    ///   - type: The `Decodable` type to decode the data into. Default is inferred.
    ///   - dateDecodingStrategy: The strategy for decoding date values. Default is `.deferredToDate`.
    ///   - keyDecodingStrategy: The strategy for decoding JSON keys. Default is `.useDefaultKeys`.
    /// - Returns: An instance of the specified `Decodable` type.
    /// - Note: If the file cannot be found, read, or decoded, this function triggers a `fatalError`.
    func decode<T: Decodable>(
        _ file: String,
        as type: T.Type = T.self,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) -> T {
        // Locate the file in the app bundle
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        // Load the file's data
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy

        do {
            // Attempt to decode the JSON data
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode \(file): missing key '\(key.stringValue)' – \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError("Failed to decode \(file): type mismatch – \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode \(file): missing \(type) value – \(context.debugDescription)")
        } catch DecodingError.dataCorrupted {
            fatalError("Failed to decode \(file): invalid JSON format")
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
    }
}
