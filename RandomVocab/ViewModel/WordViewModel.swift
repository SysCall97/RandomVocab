//
//  WordViewModel.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 19/8/24.
//

import Foundation
import Combine

class WordViewModel: ObservableObject, Equatable {
    static func == (lhs: WordViewModel, rhs: WordViewModel) -> Bool {
        lhs.wordModel.id == rhs.wordModel.id
    }
    
    let wordModel: WordModel
    @Published var isMarkedAsFavourite: Bool
    private(set) var isPhoneticsHasAudibleFile: Bool = false
    
    init(with model: WordModel, isFavourite: Bool) {
        self.wordModel = model
        self.isMarkedAsFavourite = isFavourite
        if let phonetics = model.phonetics {
            if let _ = phonetics.audio {
                self.isPhoneticsHasAudibleFile = true
            }
        }
    }
}
