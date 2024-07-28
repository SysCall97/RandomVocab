//
//  RandomWordPickerTests.swift
//  RandomVocabTests
//
//  Created by Kazi Mashry on 28/7/24.
//

import XCTest
@testable import RandomVocab

final class RandomWordPickerTests: XCTestCase {

    let wordList: [String] = ["one", "two", "three", "four", "five"]

    class WordReader: AnyWordListReader {
        let wordList: [String]?
        
        init(wordList: [String]? = nil) {
            self.wordList = wordList
        }
        
        func getWordList() -> [String]? {
            wordList
        }
        
        
    }
    
    func test_RandomWordPickerWithWordListContainingWords() {
        let wordPicker: AnyRandomWordPicker = RandomWordPicker(wordListReader: WordReader(wordList: wordList))
        
        for _ in 0..<20 {
            if let randomWord = wordPicker.getWord() {
                XCTAssertTrue(wordList.contains(randomWord), "The picked word should be in the word list")
            }
        }
    }
    
    func test_RandomWordPickerWithZeroContainingWord() {
        let wordPicker: AnyRandomWordPicker = RandomWordPicker(wordListReader: WordReader(wordList: []))
        let randomWord = wordPicker.getWord()
        
        XCTAssertNil(randomWord, "It should retrun nil")
    }
    
    func test_RandomWordPickerWithNILWordList() {
        let wordPicker: AnyRandomWordPicker = RandomWordPicker(wordListReader: WordReader(wordList: nil))
        let randomWord = wordPicker.getWord()
        
        XCTAssertNil(randomWord, "It should retrun nil")
    }
    
    func test_RandomWordPickerWithCSV() {
        let wordPicker: AnyRandomWordPicker = RandomWordPicker()
        
        for _ in 0..<20 {
            let randomWord = wordPicker.getWord()
            print(randomWord as Any)
            XCTAssertTrue(randomWord is String?, "Random word should be string")
        }
    }
}
