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
    
    func getNextWord() -> WordViewModel
    func getPrevWord() -> WordViewModel
    func markedAsFavourite(_ wordViewMode: WordViewModel)
    
}

//class WordManager: AnyWordManager {
//    
//    
//}
