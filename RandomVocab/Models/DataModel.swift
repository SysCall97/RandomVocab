//
//  DataModel.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 28/7/24.
//

import Foundation

struct APIResponseDataModel: Codable {
    let word: String
    let phonetics: [Phonetic]
    let meanings: [Meaning]
    
    struct Phonetic: Codable {
        let text: String?
        let audio: String?
    }
    
    struct Meaning: Codable {
        let partOfSpeech: String
        let definitions: [Definition]
        
        struct Definition: Codable {
            let definition: String
        }
    }
}
