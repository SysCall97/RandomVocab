//
//  Errors.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 30/7/24.
//

import Foundation


enum NetworkError: Error {
    case serverError
    case invalidData
    case contentNotFound
}

enum URLError: Error {
    case urlInitializationError
}
