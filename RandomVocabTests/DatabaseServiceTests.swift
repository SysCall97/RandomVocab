//
//  DatabaseServiceTests.swift
//  RandomVocabTests
//
//  Created by Kazi Mashry on 2/8/24.
//

import XCTest
@testable import RandomVocab

final class DatabaseServiceTests: XCTestCase {
    
    private func getAPIResponseModels() -> [[APIResponseDataModel]] {
        let words = ["blood", "programming", "money", "study"]
        let res = [
            APIResponseDataModel(word: words[0], phonetics: [APIResponseDataModel.Phonetic(text: "", audio: "")], meanings: [APIResponseDataModel.Meaning(partOfSpeech: "", definitions: [APIResponseDataModel.Meaning.Definition(definition: "")])])
        ]
        
        let res1 = [
            APIResponseDataModel(word: words[1], phonetics: [APIResponseDataModel.Phonetic(text: "", audio: "")], meanings: [APIResponseDataModel.Meaning(partOfSpeech: "", definitions: [APIResponseDataModel.Meaning.Definition(definition: "")])])
        ]
        
        return [res, res1]
    }

    func test_DatabaseServiceSave() {
        let sut = DatabaseService.shared
        let model = WordModel(from: self.getAPIResponseModels()[0])
        
        sut.save(word: model)
        
        do {
            let words = try sut.fetchWords()
            print("save:: \(words?.count)")
            XCTAssertNotNil(words, "fetchWords shouldn't return nil")
            XCTAssertTrue(words?.last?.word == "blood", "number of saved word is 1")
        } catch {
            XCTFail("It shouldn't be failed")
        }
    }
    
    func test_DatabaseServiceDelete() {
        let sut = DatabaseService.shared
        let model0 = WordModel(from: self.getAPIResponseModels()[0])
        let model1 = WordModel(from: self.getAPIResponseModels()[1])
        
        sut.save(word: model0)
        sut.save(word: model1)
        
        do {
            guard let words = try sut.fetchWords() else {
                XCTFail("Words shouldn't be nil")
                return
            }
            
            let modelToDelete = words.first!
            try sut.delete(word: modelToDelete)
            guard let words1 = try sut.fetchWords() else {
                XCTFail("Words shouldn't be nil")
                return
            }
            
            XCTAssertNotNil(words, "fetchWords shouldn't return nil")
            XCTAssertTrue(words1.count == words.count - 1, "number of saved word must be 0")
            XCTAssertFalse(try sut.isExists(word: modelToDelete), "Model should not exist after delete")
        } catch {
            XCTFail("It shouldn't be failed")
        }
    }

}
