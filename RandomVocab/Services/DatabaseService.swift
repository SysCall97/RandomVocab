//
//  DatabaseService.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 2/8/24.
//

import Foundation
import SwiftData

protocol AnyDatabaseService {
    func save(word: WordModel)
    func fetchWords() throws -> [WordModel]?
    func delete(word: WordModel) throws
    func isExists(word: WordModel) throws -> Bool
    
    func save(selectedWords: SelectedWords)
    func fetchSelectedWords(with id: String) throws -> SelectedWords?
}

class DatabaseService: AnyDatabaseService {
    static var shared = DatabaseService()
    var container: ModelContainer?
    var context: ModelContext?
    
    private init() {
        do {
            let schema = Schema([
                WordModel.self,
                SelectedWords.self
            ])
            
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: modelConfiguration)
            
            if let container {
                context = ModelContext(container)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func save(word: WordModel) {
        do {
            let existingWords = try fetchWord(with: word.id)
            if existingWords?.isEmpty == false {
                print("Word with ID \(word.id) already exists")
                return
            }
            context?.insert(word)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func fetchWord(with id: String) throws -> [WordModel]? {
        let predicate: Predicate<WordModel> = #Predicate { $0.id == id }
        let descriptor = FetchDescriptor<WordModel>(predicate: predicate)
        do {
            let result: [WordModel]? = try context?.fetch(descriptor)
            return result
        } catch {
            throw DatabaseError.fetchError
        }
    }
    
    func fetchWords() throws -> [WordModel]? {
        let descriptor = FetchDescriptor<WordModel>()
        
        do {
            let data = try context?.fetch(descriptor)
            return data
        } catch {
            throw DatabaseError.fetchError
        }
    }
    
    func delete(word: WordModel) throws {
        do {
            context?.delete(word)
            try context?.save()
        } catch {
            throw DatabaseError.deleteError
        }
    }
    
    func isExists(word: WordModel) throws -> Bool {
        do {
            let existingWords = try fetchWord(with: word.id)
            return existingWords?.isEmpty == false
        } catch {
            throw error
        }
    }
}

extension DatabaseService {
    func save(selectedWords: SelectedWords) {
        do {
            if let _ = try fetchSelectedWords(with: selectedWords.id) {
                print("Word with ID \(selectedWords.id) already exists")
                return
            }
            context?.insert(selectedWords)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchSelectedWords(with id: String) throws -> SelectedWords? {
        let predicate: Predicate<SelectedWords> = #Predicate { $0.id == id }
        let descriptor = FetchDescriptor<SelectedWords>(predicate: predicate)
        
        do {
            let result: SelectedWords? = try context?.fetch(descriptor).first
            return result
        } catch {
            throw DatabaseError.fetchError
        }
    }
}
