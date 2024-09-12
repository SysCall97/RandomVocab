//
//  DatabaseServiceTests.swift
//  RandomVocabTests
//
//  Created by Kazi Mashry on 2/8/24.
//

import XCTest
@testable import RandomVocab

final class DatabaseServiceTests: XCTestCase {
    let words = ["blood", "programming", "money", "study"]
    
    private func getAPIResponseModels() -> [[APIResponseDataModel]] {
        
        let res = [
            APIResponseDataModel(word: words[0], phonetics: [APIResponseDataModel.Phonetic(text: "", audio: "")], meanings: [APIResponseDataModel.Meaning(partOfSpeech: "", definitions: [APIResponseDataModel.Meaning.Definition(definition: "")])])
        ]
        
        let res1 = [
            APIResponseDataModel(word: words[1], phonetics: [APIResponseDataModel.Phonetic(text: "", audio: "")], meanings: [APIResponseDataModel.Meaning(partOfSpeech: "", definitions: [APIResponseDataModel.Meaning.Definition(definition: "")])])
        ]
        
        return [res, res1]
    }

    func test_DatabaseServiceSave() async {
        let sut = DatabaseService.shared
        let model = WordModel(from: self.getAPIResponseModels()[0])
        
        await sut.save(word: model)
        
        do {
            let words = try await sut.fetchWords()
            XCTAssertNotNil(words, "fetchWords shouldn't return nil")
            XCTAssertTrue(words?.last?.word == self.getAPIResponseModels()[0].first!.word, "Last word should be /'\(self.getAPIResponseModels()[0].first!.word)/'")
        } catch {
            XCTFail("It shouldn't be failed")
        }
    }
    
    func test_DatabaseServiceDelete() async {
        let sut = DatabaseService.shared
        let model0 = WordModel(from: self.getAPIResponseModels()[0])
        let model1 = WordModel(from: self.getAPIResponseModels()[1])
        
        await sut.save(word: model0)
        await sut.save(word: model1)
        
        do {
            guard let words = try await sut.fetchWords() else {
                XCTFail("Words shouldn't be nil")
                return
            }
            
            let modelToDelete = words.first!
            try await sut.delete(word: modelToDelete)
            guard let words1 = try await sut.fetchWords() else {
                XCTFail("Words shouldn't be nil")
                return
            }
            
            XCTAssertNotNil(words, "fetchWords shouldn't return nil")
            XCTAssertTrue(words1.count == words.count - 1, "number of saved word must be 0")
            let isExist = try await sut.isExists(word: modelToDelete)
            XCTAssertFalse(isExist, "Model should not exist after delete")
        } catch {
            XCTFail("It shouldn't be failed")
        }
    }
    
    func test_DatabaseServiceSaveSelectedWords() async {
        let sut: AnyDatabaseService = DatabaseService.shared
        let selectedWords = SelectedWords(words: words)
        await sut.save(selectedWords: selectedWords)
        do {
            let s = try await sut.fetchSelectedWords(with: selectedWords.id)
            XCTAssertNotNil(s, "selected words should not be nil")
        } catch {
            XCTFail("No error should be thrown here")
        }
    }
    
    private func getFutureDate() -> String? {
        let currentDate = Date()

        if let futureDate = Calendar.current.date(byAdding: .year, value: 1, to: currentDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy"
            let formattedDate = dateFormatter.string(from: futureDate)

            return formattedDate
        }
        return nil
    }
    
    func test_DatabaseServiceGetUnsetSelectedWords() async {
        let sut: AnyDatabaseService = DatabaseService.shared
        let selectedWords = SelectedWords(words: words)
//        sut.save(selectedWords: selectedWords)
        if let futureDate = self.getFutureDate() {
            do {
                let s = try await sut.fetchSelectedWords(with: futureDate)
                XCTAssertNil(s, "selected words should be nil")
            } catch {
                XCTFail("No error should be thrown here")
            }
        }
    }

}
