//
//  WordNetworkService.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 28/7/24.
//

import Foundation

protocol AnyDictionaryNetworkService {
    var baseUrl: String { get set }
    func getMeaning(for word: String) async throws -> [APIResponseDataModel]
}

final class DictionaryAPINetworkService: AnyDictionaryNetworkService {
    var baseUrl: String
    
    init(baseUrl: String = BaseUrl.dictionaryAPI) {
        self.baseUrl = baseUrl
    }
    
    func getMeaning(for word: String) async throws -> [APIResponseDataModel] {
        let url: URL = URL(string: "\(baseUrl)\(word)")!
        
        var urlRequest: URLRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            if let response = response as? HTTPURLResponse {
                
                if response.statusCode == 404 {
                    throw NetworkError.contentNotFound
                }
            }
            throw NetworkError.serverError
        }
        do {
            let decoder = JSONDecoder()
            
            return try decoder.decode([APIResponseDataModel].self, from: data)
        } catch {
            print(String(describing: error))
            throw NetworkError.invalidData
        }
    }
}
