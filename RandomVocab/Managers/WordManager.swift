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
    var wordReaderService: AnyWordListReader { get set }
    var wordMeaningFetchingService: AnyDictionaryNetworkService { get set }
    var randomWordPicker: AnyRandomWordPicker { get set }
    func getNextWord() async -> WordViewModel?
    func getPrevWord() async -> WordViewModel?
    func markedAsFavourite(_ wordViewMode: WordViewModel)
    
}

class WordManager: AnyWordManager {
    var wordReaderService: AnyWordListReader
    var wordMeaningFetchingService: AnyDictionaryNetworkService
    var randomWordPicker: AnyRandomWordPicker
    var dictionary = [String: WordViewModel]()
    var currentPosition: Int = 0
    var selectedWordsForToday = [String]()
    
    init(wordReaderService: AnyWordListReader = WordListReaderFromCSV(),
         randomWordPicker: AnyRandomWordPicker = RandomWordPicker(),
         wordMeaningFetchingService: AnyDictionaryNetworkService = DictionaryAPINetworkService()) {
        self.wordReaderService = wordReaderService
        self.randomWordPicker = randomWordPicker
        self.wordMeaningFetchingService = wordMeaningFetchingService
        
        if let wordList = wordReaderService.getWordList(from: FileNameContainer.wordListCSV) {
            selectedWordsForToday = randomWordPicker.getWords(from: wordList)
            
        }
        
    }
    
    func getNextWord() async -> WordViewModel? {
        currentPosition += 1
        if currentPosition >= CommonConstants.maxNumberOfWordsToPick {
            currentPosition -= 1
            return nil
        }
        
        let word = selectedWordsForToday[currentPosition]
        
        if dictionary.keys.contains(word) {
            return dictionary[word]
        }
        
        return await createViewModel(for: word)
    }
    
    func getPrevWord() async -> WordViewModel? {
        currentPosition -= 1
        if currentPosition >= CommonConstants.maxNumberOfWordsToPick {
            currentPosition += 1
            return nil
        }
        
        let word = selectedWordsForToday[currentPosition]
        
        if dictionary.keys.contains(word) {
            return dictionary[word]
        }
        
        return await createViewModel(for: word)
    }
    
    func markedAsFavourite(_ wordViewMode: WordViewModel) {
        //
    }
    
    private func createViewModel(for word: String) async -> WordViewModel? {
        do {
            let response = try await wordMeaningFetchingService.getMeaning(for: word)
            self.dictionary[word] = WordViewModel(from: response)
            return self.dictionary[word]
        } catch {
            return nil
        }
    }
    
}
