//
//  WordManagerTests.swift
//  RandomVocabTests
//
//  Created by Kazi Mashry on 30/7/24.
//

import XCTest
@testable import RandomVocab

final class WordManagerTests: XCTestCase {

    class MockWordListReader: AnyWordListReader {
        let words: [String]?
        init(words: [String]?) {
            self.words = words
        }
        func getWordList(from file: RandomVocab.FileNameContainer.File) -> [String]? {
            words
        }
    }
    
    class MockRandomWordPicker: AnyRandomWordPicker {
        func getWords(from words: [String]) -> [String] {
            words
        }
        
        
    }
    
    class MockDictionaryNetworkService: AnyDictionaryNetworkService {
        var baseUrl: String = "https://example.com"
        
        // This dictionary will hold the mock responses for testing
        var mockResponses: [String: [APIResponseDataModel]] = [:]
        
        func getMeaning(for word: String) async throws -> [APIResponseDataModel] {
            try! await Task.sleep(nanoseconds: 1 * 1_000_000_000)
            
            if let response = mockResponses[word] {
                return response
            } else {
                throw NSError(domain: "MockErrorDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Word not found"])
            }
        }
    }
    
    private func getMockDictionaryService() -> MockDictionaryNetworkService {
        let mockDictionaryService = MockDictionaryNetworkService()
        mockDictionaryService.mockResponses["blood"] = [
            APIResponseDataModel(word: "blood", phonetics: [APIResponseDataModel.Phonetic(text: "", audio: "")], meanings: [APIResponseDataModel.Meaning(partOfSpeech: "", definitions: [APIResponseDataModel.Meaning.Definition(definition: "")])])
        ]
        
        return mockDictionaryService
    }
    
    func test_WordManagerGetNextWordWithEmptyStringCollectionInTheFile() async {
        let sut: WordManager =
        WordManager(wordReaderService: MockWordListReader(words: nil),
                    randomWordPicker: MockRandomWordPicker(),
                    wordMeaningFetchingService: getMockDictionaryService())
        
        let res = await sut.getNextWord()
        XCTAssertNil(res, "Output should be nil")
    }
    
    func test_WordManagerGetNextWordWithZeroStringCollection() async {
        let sut: WordManager =
        WordManager(wordReaderService: MockWordListReader(words: []),
                    randomWordPicker: MockRandomWordPicker(),
                    wordMeaningFetchingService: getMockDictionaryService())
        
        let res = await sut.getNextWord()
        XCTAssertNil(res, "Output should be nil")
    }
    
    func test_WordManagerGetNextWordNotAvailableWordInTheDictionary() async {
        let sut: WordManager =
        WordManager(wordReaderService: MockWordListReader(words: ["bleed"]),
                    randomWordPicker: MockRandomWordPicker(),
                    wordMeaningFetchingService: getMockDictionaryService())
        
        let res = await sut.getNextWord()
        XCTAssertNil(res, "Output should be nil")
    }
    
    func test_WordManagerGetNextWordAvailableWordInTheDictionary() async {
        let sut: WordManager =
        WordManager(wordReaderService: MockWordListReader(words: ["blood"]),
                    randomWordPicker: MockRandomWordPicker(),
                    wordMeaningFetchingService: getMockDictionaryService())
        
        let res = await sut.getNextWord()
        XCTAssertNotNil(res, "Output should not be nil")
    }
    
    func test_WordManagerGetNextWordForMultipleTimes() async {
        let sut: WordManager =
        WordManager(wordReaderService: MockWordListReader(words: ["blood"]),
                    randomWordPicker: MockRandomWordPicker(),
                    wordMeaningFetchingService: getMockDictionaryService())
        
        var res = await sut.getNextWord()
        XCTAssertNotNil(res, "Output should not be nil")
        
        res = await sut.getNextWord()
        XCTAssertNil(res, "Output should be nil")
        
        res = await sut.getNextWord()
        XCTAssertNil(res, "Output should be nil")
    }
}
