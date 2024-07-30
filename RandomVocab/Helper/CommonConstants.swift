//
//  CommonConstants.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 30/7/24.
//

import Foundation

class BaseUrl {
    static let dictionaryAPI: String = "https://api.dictionaryapi.dev/api/v2/entries/en/"
}

class FileNameContainer {
    struct File {
        let name: String
        let type: String
    }
    
    static let wordListCSV: File = File(name: "words", type: "csv")
}
