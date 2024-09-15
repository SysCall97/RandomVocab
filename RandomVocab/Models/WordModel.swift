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
    typealias Meanings = [APIResponseDataModel.Meaning]
    var id: String
    let word: String
    var phonetics: APIResponseDataModel.Phonetic?
    var meanings: Meanings
    
    init(from response: [APIResponseDataModel]) {
        self.id = response.first!.word
        self.word = response.first?.word ?? ""
        
        var text: String? = nil
        var audio: String? = nil
        response.forEach { res in
            res.phonetics.forEach { phonetic in
                if let pText = phonetic.text {
                    if !pText.isEmpty {
                        text = pText
                    }
                }
                
                if let pAudio = phonetic.audio {
                    if !pAudio.isEmpty {
                        audio = pAudio
                    }
                }
            }
        }
        self.phonetics = APIResponseDataModel.Phonetic(text: text, audio: audio)
        self.meanings = []
        response.forEach { [self] res in
            meanings.append(contentsOf: res.meanings)
        }
    }
    
    
    init(from model: WordModel) {
        self.id = model.id
        self.word = model.word
        self.phonetics = APIResponseDataModel.Phonetic(text: model.phonetics?.text, audio: model.phonetics?.audio)
        self.meanings = []
        model.meanings.forEach { meaning in
            self.meanings.append(APIResponseDataModel.Meaning(partOfSpeech: meaning.partOfSpeech, definitions: meaning.definitions))
        }
        
    }
}
