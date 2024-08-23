//
//  RandomWordPickerTests.swift
//  RandomVocabTests
//
//  Created by Kazi Mashry on 28/7/24.
//

import XCTest
@testable import RandomVocab

final class RandomWordPickerTests: XCTestCase {
 
    let wordList: [String] = ["one", "two", "three", "four", "five", "six", "seven", "eight"]

    func test_RandomWordPickerWordsCount() {
        let sut: AnyRandomWordPicker = RandomWordPicker()
        let list = sut.getWords(from: wordList)
        XCTAssertEqual(list.count, CommonConstants.MAX_WORD_LIMIT, "RandomWordPicker must return the list of size \(CommonConstants.MAX_WORD_LIMIT)")
    }
    
    func test_RandomWordPickerWithNoWordListAsParam() {
        let sut: AnyRandomWordPicker = RandomWordPicker()
        let list = sut.getWords(from: [])
        XCTAssertEqual(list.count, 0, "RandomWordPicker must return a empty list")
    }
}
