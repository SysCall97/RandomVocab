//
//  WordNetworkService.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 28/7/24.
//

import Foundation

protocol AnyDictionaryNetworkService {
    func getMeaning(for word: String) async throws -> [APIResponseDataModel]
}

final class DictionaryAPINetworkService: AnyDictionaryNetworkService {
    func getMeaning(for word: String) async throws -> [APIResponseDataModel] {
        let url: URL = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)")!
        
        var urlRequest: URLRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.serverError
        }
        print(data)
        do {
            let decoder = JSONDecoder()
            
            return try decoder.decode([APIResponseDataModel].self, from: data)
        } catch {
            print(String(describing: error))
            throw NetworkError.invalidData
        }
    }
}

enum NetworkError: Error {
    case serverError
    case invalidData
}
