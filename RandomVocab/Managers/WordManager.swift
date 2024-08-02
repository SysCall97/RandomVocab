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
    func getNextWord() async -> WordModel?
    func getPrevWord() async -> WordModel?
    func markedAsFavourite(_ wordViewMode: WordModel)
    
}

class WordManager: AnyWordManager {
    var wordReaderService: AnyWordListReader
    var wordMeaningFetchingService: AnyDictionaryNetworkService
    var randomWordPicker: AnyRandomWordPicker
    var dictionary = [String: WordModel]()
    var currentPosition: Int = -1
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
    
    func markedAsFavourite(_ wordViewMode: WordModel) {
        //
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
