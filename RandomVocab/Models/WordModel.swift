//
//  WordViewModel.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 30/7/24.
//

import Foundation
import SwiftData

@Model
class WordModel {
    var id: String
    let word: String
    let phonetics: APIResponseDataModel.Phonetic?
    var meanings: [APIResponseDataModel.Meaning]
    
    init(from response: [APIResponseDataModel]) {
        self.id = response.first!.word
        self.word = response.first?.word ?? ""
        self.phonetics = (response.first?.phonetics.first) ?? nil
        self.meanings = []
        response.forEach { [self] res in
            meanings.append(contentsOf: res.meanings)
        }
    }
}
