//
//  SelectedWords.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 10/8/24.
//

import Foundation
import SwiftData

@Model
class SelectedWords {
    let words: [String]
    let formattedDate: String
    let id: String
    
    init(words: [String]) {
        self.words = words
        self.formattedDate = DateFormatter().getFormattedCurrentDateString()
        self.id = DateFormatter().getFormattedCurrentDateString()
    }
}

