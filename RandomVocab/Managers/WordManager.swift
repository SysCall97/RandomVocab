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
//    var databaseService: AnyDatabaseService? { get set }
//    var wordReaderService: AnyWordListReader { get set }
//    var wordMeaningFetchingService: AnyDictionaryNetworkService { get set }
//    var randomWordPicker: AnyRandomWordPicker { get set }
    func initiateAllWordViewModels() async
    func getNextWord() async -> WordViewModel?
    func getPrevWord() async -> WordViewModel?
    func reset() async
    func markAsFavourite(_ wordViewModel: WordViewModel) async
    func unmarkAsFavourite(_ wordViewModel: WordViewModel) async
    func getFavouriteWords() async -> [WordViewModel]?
    
}

actor WordManager: AnyWordManager {
    private var databaseService: AnyDatabaseService?
    private var wordReaderService: AnyWordListReader
    private var wordMeaningFetchingService: AnyDictionaryNetworkService
    private var randomWordPicker: AnyRandomWordPicker
    private var dictionary = [String: WordViewModel]()
    private var favouriteWords: [WordViewModel]? = nil
    var currentPosition: Int = -1
    var selectedWordsForToday = [String]()
    
    init(databaseService: AnyDatabaseService? = DatabaseService.shared,
         wordReaderService: AnyWordListReader = WordListReaderFromCSV(),
         randomWordPicker: AnyRandomWordPicker = RandomWordPicker(),
         wordMeaningFetchingService: AnyDictionaryNetworkService = DictionaryAPINetworkService()) async {
        self.wordReaderService = wordReaderService
        self.randomWordPicker = randomWordPicker
        self.wordMeaningFetchingService = wordMeaningFetchingService
        self.databaseService = databaseService
        
        await self.fetchTodaysWords()
        
    }
    
    private func fetchTodaysWords() async {
        let formattedDate = DateFormatter().getFormattedCurrentDateString()
        do {
            if let selectedWords = try await databaseService?.fetchSelectedWords(with: formattedDate) {
                self.selectedWordsForToday = randomWordPicker.getWords(from: selectedWords.words)
            } else {
                await self.selectWordsFromFile()
            }
        } catch {
            await self.selectWordsFromFile()
        }
        
    }
    
    private func selectWordsFromFile() async {
        if let wordList = await wordReaderService.getWordList(from: FileNameContainer.wordListCSV) {
            selectedWordsForToday = randomWordPicker.getWords(from: wordList)
            let selectedWords = SelectedWords(words: selectedWordsForToday)
            await databaseService?.save(selectedWords: selectedWords)
        }
    }
    
    func initiateAllWordViewModels() async {
        await withTaskGroup(of: (Int, WordViewModel?).self) { group in
            for (index, word) in selectedWordsForToday.enumerated() {
                group.addTask { [self] in
                    let viewModel = await createViewModel(for: word)
                    return (index, viewModel)
                }
            }
            
            for await (index, wordViewModel) in group {
                if let wordViewModel {
                    wordViewModel.serialNo = index + 1
                }
            }
        }
    }
    
    func reset() {
        self.currentPosition = -1
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
    
    func markAsFavourite(_ wordViewModel: WordViewModel) async {
        let _ = await getFavouriteWords()
        if !(favouriteWords?.contains(where: { $0.wordModel.id == wordViewModel.wordModel.id }) ?? false) {
            favouriteWords?.append(wordViewModel)
            await databaseService?.save(word: wordViewModel.wordModel)
            wordViewModel.isMarkedAsFavourite = true
        }
        
    }
    
    func unmarkAsFavourite(_ wordViewModel: WordViewModel) async {
        var _ = await getFavouriteWords()
        if let index = favouriteWords?.firstIndex(where: { $0.wordModel.id == wordViewModel.wordModel.id }) {
            do {
                try await databaseService?.delete(word: wordViewModel.wordModel)
                favouriteWords?.remove(at: index)
                wordViewModel.isMarkedAsFavourite = false
            } catch {}
        }
    }
    
    func getFavouriteWords() async -> [WordViewModel]? {
        if let favouriteWords = self.favouriteWords {
            return favouriteWords
        }
        do {
            let words = try await databaseService?.fetchWords()
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
    
    private func isFavourite(model: WordModel) async -> Bool {
        let _ = await getFavouriteWords()
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
            let isFavourite = await self.isFavourite(model: model)
            
            self.dictionary[word] = WordViewModel(with: model, serialNo: currentPosition+1, isFavourite: isFavourite)
            return self.dictionary[word]
        } catch {
            return nil
        }
    }
    
}
