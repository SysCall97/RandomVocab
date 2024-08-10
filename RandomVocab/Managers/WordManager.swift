//
//  WordManager.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 30/7/24.
//

import Foundation

/**
    Responsibilities of WordManager:
        - get words from reader
        - call APIs to get the full meaning
        - provide max 5 words per day
 */
protocol AnyWordManager {
    var databaseService: AnyDatabaseService? { get set }
    var wordReaderService: AnyWordListReader { get set }
    var wordMeaningFetchingService: AnyDictionaryNetworkService { get set }
    var randomWordPicker: AnyRandomWordPicker { get set }
    func getNextWord() async -> WordModel?
    func getPrevWord() async -> WordModel?
    func markedAsFavourite(_ wordMode: WordModel)
    func getFavouriteWords() -> [WordModel]?
    
}

class WordManager: AnyWordManager {
    var databaseService: AnyDatabaseService?
    var wordReaderService: AnyWordListReader
    var wordMeaningFetchingService: AnyDictionaryNetworkService
    var randomWordPicker: AnyRandomWordPicker
    var dictionary = [String: WordModel]()
    var currentPosition: Int = -1
    var selectedWordsForToday = [String]()
    
    init(databaseService: AnyDatabaseService? = DatabaseService.shared,
         wordReaderService: AnyWordListReader = WordListReaderFromCSV(),
         randomWordPicker: AnyRandomWordPicker = RandomWordPicker(),
         wordMeaningFetchingService: AnyDictionaryNetworkService = DictionaryAPINetworkService()) {
        self.wordReaderService = wordReaderService
        self.randomWordPicker = randomWordPicker
        self.wordMeaningFetchingService = wordMeaningFetchingService
        self.databaseService = databaseService
        
        self.fetchTodaysWords()
        
    }
    
    private func fetchTodaysWords() {
        let formattedDate = DateFormatter().getFormattedCurrentDateString()
        do {
            if let selectedWords = try databaseService?.fetchSelectedWords(with: formattedDate) {
                self.selectedWordsForToday = randomWordPicker.getWords(from: selectedWords.words)
            } else {
                self.selectWordsFromFile()
            }
        } catch {
            self.selectWordsFromFile()
        }
        
    }
    
    private func selectWordsFromFile() {
        if let wordList = wordReaderService.getWordList(from: FileNameContainer.wordListCSV) {
            selectedWordsForToday = randomWordPicker.getWords(from: wordList)
            let selectedWords = SelectedWords(words: selectedWordsForToday)
            databaseService?.save(selectedWords: selectedWords)
        }
    }
    
    func getNextWord() async -> WordModel? {
        currentPosition += 1
        if currentPosition >= selectedWordsForToday.count {
            currentPosition -= 1
            return nil
        }
        
        let word = selectedWordsForToday[currentPosition]
        
        if dictionary.keys.contains(word) {
            return dictionary[word]
        }
        
        return await createViewModel(for: word)
    }
    
    func getPrevWord() async -> WordModel? {
        currentPosition -= 1
        if currentPosition < 0 {
            currentPosition += 1
            return nil
        }
        
        let word = selectedWordsForToday[currentPosition]
        
        if dictionary.keys.contains(word) {
            return dictionary[word]
        }
        
        return await createViewModel(for: word)
    }
    
    func markedAsFavourite(_ wordMode: WordModel) {
        databaseService?.save(word: wordMode)
    }
    
    func getFavouriteWords() -> [WordModel]? {
        do {
            let words = try databaseService?.fetchWords()
            return words
            
        } catch {
            return nil
        }
    }
    
    private func createViewModel(for word: String) async -> WordModel? {
        do {
            let response = try await wordMeaningFetchingService.getMeaning(for: word)
            self.dictionary[word] = WordModel(from: response)
            return self.dictionary[word]
        } catch {
            return nil
        }
    }
    
}
