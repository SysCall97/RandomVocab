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
    func getNextWord() async -> WordViewModel?
    func getPrevWord() async -> WordViewModel?
    func markAsFavourite(_ wordViewModel: WordViewModel)
    func unmarkAsFavourite(_ wordViewModel: WordViewModel)
    func getFavouriteWords() -> [WordViewModel]?
    
}

class WordManager: AnyWordManager {
    var databaseService: AnyDatabaseService?
    var wordReaderService: AnyWordListReader
    var wordMeaningFetchingService: AnyDictionaryNetworkService
    var randomWordPicker: AnyRandomWordPicker
    var dictionary = [String: WordViewModel]()
    private var favouriteWords: [WordViewModel]? = nil
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
    
    func getNextWord() async -> WordViewModel? {
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
    
    func getPrevWord() async -> WordViewModel? {
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
    
    func markAsFavourite(_ wordViewModel: WordViewModel) {
        let _ = getFavouriteWords()
        if !(favouriteWords?.contains(where: { $0.wordModel.id == wordViewModel.wordModel.id }) ?? false) {
            favouriteWords?.append(wordViewModel)
            databaseService?.save(word: wordViewModel.wordModel)
            wordViewModel.isMarkedAsFavourite = true
        }
        
    }
    
    func unmarkAsFavourite(_ wordViewModel: WordViewModel) {
        var _ = getFavouriteWords()
        if let index = favouriteWords?.firstIndex(where: { $0.wordModel.id == wordViewModel.wordModel.id }) {
            do {
                try databaseService?.delete(word: wordViewModel.wordModel)
                favouriteWords?.remove(at: index)
                wordViewModel.isMarkedAsFavourite = false
            } catch {}
        }
    }
    
    func getFavouriteWords() -> [WordViewModel]? {
        if let favouriteWords = self.favouriteWords {
            return favouriteWords
        }
        do {
            let words = try databaseService?.fetchWords()
            var wordViewModels = [WordViewModel]()
            words?.enumerated().forEach({ (index, model) in
                wordViewModels.append(WordViewModel(with: model, serialNo: index+1, isFavourite: true))
            })
            self.favouriteWords = wordViewModels
            return favouriteWords
            
        } catch {
            return nil
        }
    }
    
    private func isFavourite(model: WordModel) -> Bool {
        let _ = getFavouriteWords()
        if favouriteWords == nil {
            return false
        } else if !(favouriteWords?.contains(where: { $0.wordModel.id == model.id }) ?? false) {
            return false
        }
        return true
    }
    
    private func createViewModel(for word: String) async -> WordViewModel? {
        do {
            let response = try await wordMeaningFetchingService.getMeaning(for: word)
            let model = WordModel(from: response)
            let isFavourite = self.isFavourite(model: model)
            
            self.dictionary[word] = WordViewModel(with: model, serialNo: currentPosition+1, isFavourite: isFavourite)
            return self.dictionary[word]
        } catch {
            return nil
        }
    }
    
}
