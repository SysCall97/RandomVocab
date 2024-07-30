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

    class MockWordReader: AnyWordListReader {
        func getWordList(from file: RandomVocab.FileNameContainer.File) -> [String]? {
            wordList
        }
        
        let wordList: [String]?
        
        init(wordList: [String]? = nil) {
            self.wordList = wordList
        }
        
        
    }
    
    func test_RandomWordPickerWithWordListContainingWords() {
        let sut: AnyRandomWordPicker = RandomWordPicker(wordListReader: MockWordReader(wordList: wordList))
        
        for _ in 0..<20 {
            if let randomWord = sut.getWord(from: FileNameContainer.File(name: "", type: "")) {
                XCTAssertTrue(wordList.contains(randomWord), "The picked word should be in the word list")
            }
        }
    }
    
    func test_RandomWordPickerWithZeroContainingWord() {
        let sut: AnyRandomWordPicker = RandomWordPicker(wordListReader: MockWordReader(wordList: []))
        let randomWord = sut.getWord(from: FileNameContainer.File(name: "", type: ""))
        
        XCTAssertNil(randomWord, "It should retrun nil")
    }
    
    func test_RandomWordPickerWithNILWordList() {
        let sut: AnyRandomWordPicker = RandomWordPicker(wordListReader: MockWordReader(wordList: nil))
        let randomWord = sut.getWord(from: FileNameContainer.File(name: "", type: ""))
        
        XCTAssertNil(randomWord, "It should retrun nil")
    }
    
    func test_RandomWordPickerWithNILWordListAfterGettingDataOnPreviousNotNILCall() {
        let sut: AnyRandomWordPicker = RandomWordPicker()
        let _ = sut.getWord(from: FileNameContainer.wordListCSV)
        let randomWord = sut.getWord(from: FileNameContainer.File(name: "", type: ""))
        
        XCTAssertNil(randomWord, "It should retrun nil")
    }
    
    func test_RandomWordPickerWithCSV() {
        let sut: AnyRandomWordPicker = RandomWordPicker()
        
        for _ in 0..<20 {
            let randomWord = sut.getWord(from: FileNameContainer.wordListCSV)
            print(randomWord as Any)
            XCTAssertTrue(randomWord is String?, "Random word should be string")
        }
    }
}
