//
//  WordListReader.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 28/7/24.
//

import Foundation

protocol AnyWordListReader {
    func getWordList(from file: FileNameContainer.File) async -> [String]?
}

actor WordListReaderFromCSV: AnyWordListReader {
    
    func getWordList(from file: FileNameContainer.File) -> [String]? {
        guard let path = Bundle.main.path(forResource: file.name, ofType: file.type) else {
            print("CSV file not found.")
            return nil
        }
        
        do {
            let content = try String(contentsOfFile: path)
            let words = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
            return words
        } catch {
            print("Error reading CSV file: \(error.localizedDescription)")
            return nil
        }
    }
    
    
}
