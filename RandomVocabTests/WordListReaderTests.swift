//
//  WordListReaderTests.swift
//  RandomVocabTests
//
//  Created by Kazi Mashry on 30/7/24.
//

import XCTest
@testable import RandomVocab

final class WordListReaderTests: XCTestCase {
    
    func test_WordListReaderFromCSVFileNotFound() {
        let sut: AnyWordListReader = WordListReaderFromCSV()
        let nullFile = FileNameContainer.File(name: "", type: "")
        
        XCTAssertNil(sut.getWordList(from: nullFile), "No string collection should be returned")
    }
    
    func test_WordListReaderFromCSVGetNILAfterGettingRightDataPreviously() {
        let sut: AnyWordListReader = WordListReaderFromCSV()
        let _ = sut.getWordList(from: FileNameContainer.wordListCSV)
        let nullFile = FileNameContainer.File(name: "", type: "")
        
        XCTAssertNil(sut.getWordList(from: nullFile), "No string collection should be returned")
    }
    
    func test_WordListReaderFromCSVHappyPath() {
        let sut: AnyWordListReader = WordListReaderFromCSV()
        let wordCollection = sut.getWordList(from: FileNameContainer.wordListCSV)
        
        XCTAssertNotNil(wordCollection, "A string collection should be returned")
        XCTAssertTrue(wordCollection!.count > 0, "It must return a non-empty string collection")
    }

}
