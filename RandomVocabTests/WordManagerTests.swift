//
//  WordManagerTests.swift
//  RandomVocabTests
//
//  Created by Kazi Mashry on 30/7/24.
//

import XCTest
@testable import RandomVocab

final class WordManagerTests: XCTestCase {
    
    let words = ["blood", "programming", "money", "study"]

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
            print("MASHRY:: getMeaning: test")
            try! await Task.sleep(nanoseconds: 1 * 1_000_000_000)
            
            if let response = mockResponses[word] {
                return response
            } else {
                throw NSError(domain: "MockErrorDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Word not found"])
            }
        }
    }
    
    class MockDatabaseService: AnyDatabaseService {
        private let dictionary: MockDictionaryNetworkService
        init(dictionary: MockDictionaryNetworkService) {
            self.dictionary = dictionary
        }
        func save(word: RandomVocab.WordModel) {
            //
        }
        
        func fetchWords() throws -> [RandomVocab.WordModel]? {
            var res = [RandomVocab.WordModel]()
            dictionary.mockResponses.values.forEach { apiResponse in
                let m = RandomVocab.WordModel(from: apiResponse)
                res.append(m)
            }
            
            return res
        }
        
        func delete(word: RandomVocab.WordModel) throws {
            //
        }
        
        func isExists(word: RandomVocab.WordModel) throws -> Bool {
            return true
        }
        
        func save(selectedWords: RandomVocab.SelectedWords) {
            //
        }
        
        func fetchSelectedWords(with id: String) throws -> RandomVocab.SelectedWords? {
            var res = RandomVocab.SelectedWords(words: ["blood", "programming", "money", "study"])
            
            return res
        }
        
        
    }
    
    private func getMockDictionaryService() -> MockDictionaryNetworkService {
        let mockDictionaryService = MockDictionaryNetworkService()
        
        mockDictionaryService.mockResponses[words[0]] = [
            APIResponseDataModel(word: words[0], phonetics: [APIResponseDataModel.Phonetic(text: "", audio: "")], meanings: [APIResponseDataModel.Meaning(partOfSpeech: "", definitions: [APIResponseDataModel.Meaning.Definition(definition: "")])])
        ]
        
        mockDictionaryService.mockResponses[words[1]] = [
            APIResponseDataModel(word: words[1], phonetics: [APIResponseDataModel.Phonetic(text: "", audio: "")], meanings: [APIResponseDataModel.Meaning(partOfSpeech: "", definitions: [APIResponseDataModel.Meaning.Definition(definition: "")])])
        ]
        
        mockDictionaryService.mockResponses[words[3]] = [
            APIResponseDataModel(word: words[3], phonetics: [APIResponseDataModel.Phonetic(text: "", audio: "")], meanings: [APIResponseDataModel.Meaning(partOfSpeech: "", definitions: [APIResponseDataModel.Meaning.Definition(definition: "")])])
        ]
        
        
        return mockDictionaryService
    }
    
    func test_WordManagerGetNextWordWithEmptyStringCollectionInTheFile() async {
        let sut: WordManager =
        WordManager(databaseService: nil,
                    wordReaderService: MockWordListReader(words: nil),
                    randomWordPicker: MockRandomWordPicker(),
                    wordMeaningFetchingService: getMockDictionaryService())
        
        let res = await sut.getNextWord()
        XCTAssertNil(res, "Output should be nil")
    }
    
    func test_WordManagerGetNextWordWithZeroStringCollection() async {
        let sut: WordManager =
        WordManager(databaseService: nil,
                    wordReaderService: MockWordListReader(words: []),
                    randomWordPicker: MockRandomWordPicker(),
                    wordMeaningFetchingService: getMockDictionaryService())
        
        let res = await sut.getNextWord()
        XCTAssertNil(res, "Output should be nil")
    }
    
    func test_WordManagerGetNextWordNotAvailableWordInTheDictionary() async {
        let sut: WordManager =
        WordManager(databaseService: nil,
                    wordReaderService: MockWordListReader(words: ["bleed"]),
                    randomWordPicker: MockRandomWordPicker(),
                    wordMeaningFetchingService: getMockDictionaryService())
        
        let res = await sut.getNextWord()
        XCTAssertNil(res, "Output should be nil")
    }
    
    func test_WordManagerGetNextWordAvailableWordInTheDictionary() async {
        let sut: WordManager =
        WordManager(databaseService: MockDatabaseService(dictionary: getMockDictionaryService()),
                    wordReaderService: MockWordListReader(words: ["blood"]),
                    randomWordPicker: MockRandomWordPicker(),
                    wordMeaningFetchingService: getMockDictionaryService())
        
        let res = await sut.getNextWord()
        XCTAssertNotNil(res, "Output should not be nil")
    }
    
    func test_WordManagerGetNextWordForMultipleTimes() async {
        let sut: WordManager =
        WordManager(databaseService: MockDatabaseService(dictionary: getMockDictionaryService()),
                    wordReaderService: MockWordListReader(words: words),
                    randomWordPicker: MockRandomWordPicker(),
                    wordMeaningFetchingService: getMockDictionaryService())
        
        var res = await sut.getNextWord()
        XCTAssertNotNil(res, "Output should not be nil")
        XCTAssertEqual(res!.word, words[0], "Name didn't matched")
        
        res = await sut.getNextWord()
        XCTAssertNotNil(res, "Output should be nil")
        XCTAssertEqual(res!.word, words[1], "Name didn't matched")
        
        res = await sut.getNextWord()
        XCTAssertNil(res, "Output should be nil")
        
        res = await sut.getNextWord()
        XCTAssertNotNil(res, "Output should be nil")
        XCTAssertEqual(res!.word, words[3], "Name didn't matched")
    }
    
    func test_WordManagerGetPrevWordWithEmptyStringCollectionInTheFile() async {
        let sut: WordManager =
        WordManager(databaseService: MockDatabaseService(dictionary: getMockDictionaryService()),
                    wordReaderService: MockWordListReader(words: nil),
                    randomWordPicker: MockRandomWordPicker(),
                    wordMeaningFetchingService: getMockDictionaryService())
        
        let res = await sut.getPrevWord()
        XCTAssertNil(res, "Output should be nil")
    }
    
    func test_WordManagerGetPrevWordWithZeroStringCollection() async {
        let sut: WordManager =
        WordManager(databaseService: MockDatabaseService(dictionary: getMockDictionaryService()),
                    wordReaderService: MockWordListReader(words: []),
                    randomWordPicker: MockRandomWordPicker(),
                    wordMeaningFetchingService: getMockDictionaryService())
        
        let res = await sut.getPrevWord()
        XCTAssertNil(res, "Output should be nil")
    }
    
    func test_WordManagerGetPrevWordNotAvailableWordInTheDictionary() async {
        let sut: WordManager =
        WordManager(databaseService: nil,
                    wordReaderService: MockWordListReader(words: ["bleed"]),
                    randomWordPicker: MockRandomWordPicker(),
                    wordMeaningFetchingService: getMockDictionaryService())
        
        let res = await sut.getNextWord()
        XCTAssertNil(res, "Output should be nil")
    }
    
    func test_WordManagerGetPrevWordCallWithNoNextWordCallAtFirst() async {
        let sut: WordManager =
        WordManager(databaseService: MockDatabaseService(dictionary: getMockDictionaryService()),
                    wordReaderService: MockWordListReader(words: ["blood"]),
                    randomWordPicker: MockRandomWordPicker(),
                    wordMeaningFetchingService: getMockDictionaryService())
        
        let res = await sut.getPrevWord()
        XCTAssertNil(res, "Output should be nil")
    }
    
    func test_WordManagerGetWordForWhomNetwordCallDoneAlready() async {
        let sut: WordManager =
        WordManager(databaseService: MockDatabaseService(dictionary: getMockDictionaryService()),
                    wordReaderService: MockWordListReader(words: words),
                    randomWordPicker: MockRandomWordPicker(),
                    wordMeaningFetchingService: getMockDictionaryService())
        
        let _ = await sut.getNextWord() // 1st word with API call
        let _ = await sut.getNextWord() // 2nd word with API call
        var startTime = Date()
        let _ = await sut.getPrevWord() // 1st word without API call
        var endTime = Date()
        
        var totalTime = endTime.timeIntervalSince(startTime)
        
        XCTAssertTrue(totalTime < 1.0, "It should not call API for already existing word")
        
        startTime = Date()
        let _ = await sut.getNextWord() // 2nd word without API call
        endTime = Date()
        
        totalTime = endTime.timeIntervalSince(startTime)
        
        XCTAssertTrue(totalTime < 1.0, "It should not call API for already existing word")
    }
    
    func test_WordManagerFavouriteWordsSetGet() async {
        let sut: WordManager =
        WordManager(wordReaderService: MockWordListReader(words: words),
                    randomWordPicker: MockRandomWordPicker(),
                    wordMeaningFetchingService: getMockDictionaryService())
        var word = await sut.getNextWord()
        sut.markedAsFavourite(word!)
        word = await sut.getNextWord()
        sut.markedAsFavourite(word!)
        
        let favouriteWords = sut.getFavouriteWords()
        XCTAssertNotNil(favouriteWords, "Favourite words should not be nil")
        XCTAssertTrue(favouriteWords?.count == 2, "There are 3 fav words")
        
    }
    
    func test_WordManagerWithSameElementsInTheSameDay() {
        let sut1: WordManager = WordManager()
        let list1 = sut1.selectedWordsForToday
        let sut2: WordManager = WordManager()
        let list2 = sut2.selectedWordsForToday
        
        let sortedList1 = list1.sorted()
        let sortedList2 = list2.sorted()
        XCTAssertEqual(sortedList1, sortedList2, "The lists should contain the same elements")
    }
    
}
