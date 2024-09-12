//
//  WordListReaderTests.swift
//  RandomVocabTests
//
//  Created by Kazi Mashry on 30/7/24.
//

import XCTest
@testable import RandomVocab

final class WordListReaderTests: XCTestCase {
    
    func test_WordListReaderFromCSVFileNotFound() async {
        let sut: AnyWordListReader = WordListReaderFromCSV()
        let nullFile = FileNameContainer.File(name: "", type: "")
        let response = await sut.getWordList(from: nullFile)
        XCTAssertNil(response, "No string collection should be returned")
    }
    
    func test_WordListReaderFromCSVGetNILAfterGettingRightDataPreviously() async {
        let sut: AnyWordListReader = WordListReaderFromCSV()
        let _ = await sut.getWordList(from: FileNameContainer.wordListCSV)
        let nullFile = FileNameContainer.File(name: "", type: "")
        let response = await sut.getWordList(from: nullFile)
        XCTAssertNil(response, "No string collection should be returned")
    }
    
    func test_WordListReaderFromCSVHappyPath() async {
        let sut: AnyWordListReader = WordListReaderFromCSV()
        let wordCollection = await sut.getWordList(from: FileNameContainer.wordListCSV)
        
        XCTAssertNotNil(wordCollection, "A string collection should be returned")
        XCTAssertTrue(wordCollection!.count > 0, "It must return a non-empty string collection")
    }

}
