//
//  WordListReader.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 28/7/24.
//

import Foundation

protocol AnyWordListReader {
    func getWordList() -> [String]?
}

final class WordListReaderFromCSV: AnyWordListReader {
    static let shared: AnyWordListReader = WordListReaderFromCSV()
    private var words: [String]? = nil
    
    private init() {}
    
    func getWordList() -> [String]? {
        if let words {
            return words
        }
        guard let path = Bundle.main.path(forResource: "words", ofType: "csv") else {
            print("CSV file not found.")
            return nil
        }
        
        do {
            let content = try String(contentsOfFile: path)
            words = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
            return words
        } catch {
            print("Error reading CSV file: \(error.localizedDescription)")
            return nil
        }
    }
    
    
}
