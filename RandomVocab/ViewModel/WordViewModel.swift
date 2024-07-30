//
//  WordViewModel.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 30/7/24.
//

import Foundation

class WordViewModel {
    let word: String
    let phonetics: APIResponseDataModel.Phonetic
    var meanings: [APIResponseDataModel.Meaning]
    
    init(from response: [APIResponseDataModel]) {
        self.word = response.first?.word ?? ""
        self.phonetics = (response.first?.phonetics.first)!
        self.meanings = []
        response.forEach { [self] res in
            meanings.append(contentsOf: res.meanings)
        }
    }
}
