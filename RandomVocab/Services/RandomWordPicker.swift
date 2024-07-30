//
//  RandomWordPicker.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 28/7/24.
//

import Foundation

protocol AnyRandomWordPicker {
    func getWords(from words: [String]) -> [String]
}

final class RandomWordPicker: AnyRandomWordPicker {
    
    func getWords(from words: [String]) -> [String] {
        let shuffledArray = words.shuffled()
        let resultArray = Array(shuffledArray.prefix(5))
        return resultArray
    }
    
    
}
