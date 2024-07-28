//
//  RandomWordPicker.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 28/7/24.
//

import Foundation

protocol AnyRandomWordPicker {
    var wordListReader: AnyWordListReader { get set }
    func getWord() -> String?
}

final class RandomWordPicker: AnyRandomWordPicker {
    var wordListReader: AnyWordListReader
    
    init(wordListReader: AnyWordListReader = WordListReaderFromCSV.shared) {
        self.wordListReader = wordListReader
    }
    
    
    func getWord() -> String? {
        if let wordList: [String] = wordListReader.getWordList() {
            if wordList.isEmpty {
                return nil
            }
            return wordList.randomElement() ?? nil
        }
        return nil
    }
    
    
}
