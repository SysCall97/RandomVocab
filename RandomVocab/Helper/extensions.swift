//
//  extensions.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 10/8/24.
//

import Foundation

extension DateFormatter {
    func getFormattedCurrentDateString() -> String {
        self.dateFormat = "dd/MM/yy"
        return self.string(from: Date())
    }
}
