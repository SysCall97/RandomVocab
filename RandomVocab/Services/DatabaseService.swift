//
//  DatabaseService.swift
//  RandomVocab
//
//  Created by Kazi Mashry on 2/8/24.
//

import Foundation
import SwiftData

protocol AnyDatabaseService {
    func save(word: WordModel) async
    func fetchWords() async throws -> [WordModel]?
    func delete(word: WordModel) async throws
    func isExists(word: WordModel) async throws -> Bool
    
    func save(selectedWords: SelectedWords) async
    func fetchSelectedWords(with id: String) async throws -> SelectedWords?
}

actor DatabaseService: AnyDatabaseService, ModelActor {
    nonisolated let modelContainer: ModelContainer
    nonisolated let modelExecutor: ModelExecutor
    
    static var shared = DatabaseService()
    
    static let modelContainer: ModelContainer = {
        do {
            let schema = Schema([
                WordModel.self,
                SelectedWords.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            return try ModelContainer(for: schema, configurations: modelConfiguration)
        } catch {
            fatalError()
        }
    }()
    var context: ModelContext?
    
    private init() {
        let container = DatabaseService.modelContainer
        self.modelContainer = container
        self.context = ModelContext(container)
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: context!)
    }
    
    func save(word: WordModel) async {
        do {
            let existingWords = try await fetchWord(with: word.id)
            if existingWords?.isEmpty == false {
                print("Word with ID \(word.id) already exists")
                return
            }
            context?.insert(word)
            try context?.save()
        } catch {
            print("Failed to save word: \(error.localizedDescription)")
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
        let id = word.id
        let fetchDescriptor = FetchDescriptor<WordModel>(predicate: #Predicate { $0.id == id })
            
            do {
                let fetchedModels = try context?.fetch(fetchDescriptor)
                if let wordModel = fetchedModels?.first {
                    context?.delete(wordModel)
                    try context?.save() // Save the changes after deletion
                } else {
                    print("No WordModel found with the id: \(id)")
                }
            } catch {
                print("Failed to delete WordModel: \(error)")
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
            try context?.save()
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
