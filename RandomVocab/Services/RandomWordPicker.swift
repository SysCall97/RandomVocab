//
//  RandomWordPicker.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 28/7/24.
//

import Foundation

protocol AnyRandomWordPicker {
    var wordListReader: AnyWordListReader { get set }
    func getWord(from file: FileNameContainer.File) -> String?
}

final class RandomWordPicker: AnyRandomWordPicker {
    var wordListReader: AnyWordListReader
    
    init(wordListReader: AnyWordListReader = WordListReaderFromCSV.shared) {
        self.wordListReader = wordListReader
    }
    
    
    func getWord(from file: FileNameContainer.File) -> String? {
        if let wordList: [String] = wordListReader.getWordList(from: file) {
            if wordList.isEmpty {
                return nil
            }
            return wordList.randomElement() ?? nil
        }
        return nil
    }
    
    
}
