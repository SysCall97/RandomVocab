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
        XCTAssertEqual(list.count, CommonConstants.maxNumberOfWordsToPick, "RandomWordPicker must return the list of size \(CommonConstants.maxNumberOfWordsToPick)")
    }
    
    func test_RandomWordPickerWithNoWordListAsParam() {
        let sut: AnyRandomWordPicker = RandomWordPicker()
        let list = sut.getWords(from: [])
        XCTAssertEqual(list.count, 0, "RandomWordPicker must return a empty list")
    }
    
    func test_RandomWordPickerWithSameElementsInTheSameDay() {
        var sut: AnyRandomWordPicker = RandomWordPicker()
        let list1 = sut.getWords(from: wordList)
        sut = RandomWordPicker()
        let list2 = sut.getWords(from: wordList)
        
        
        let sortedList1 = list1.sorted()
        let sortedList2 = list2.sorted()
        XCTAssertEqual(sortedList1, sortedList2, "The lists should contain the same elements")
        
    }
}
