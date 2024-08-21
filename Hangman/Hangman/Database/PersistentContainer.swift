//
//  PersistentContainer.swift
//  Hangman
//
//  Created by Полина Лущевская on 25.06.24.
//

import CoreData

class PersistentContainer: NSPersistentContainer {
    static let shared = PersistentContainer(name: "Model")
    
    private override init(name: String, managedObjectModel model: NSManagedObjectModel) {
        super.init(name: name, managedObjectModel: model)
        self.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        loadWordsIfNeeded()
    }

    func fetchRandomWord(completion: @escaping (String?) -> Void) {
        let context = self.newBackgroundContext()
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        
        do {
            let words = try context.fetch(fetchRequest)
            if let randomWord = words.randomElement() {
                completion(randomWord.text)
            } else {
                completion(nil)
            }
        } catch {
            print("Error fetching random word:", error.localizedDescription)
            completion(nil)
        }
    }



    func loadWordsIfNeeded() {
        let context = self.newBackgroundContext()
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                let words = [
                    ("SWIFT", 1),
                    ("OBJECTIVEC", 2),
                    ("VARIABLE", 1),
                    ("CONSTANT", 1),
                    ("XCODE", 2),
                    ("LANGUAGE", 4),
                    ("PYTHON", 1),
                    ("PYCHARM", 2),
                    ("JAVA", 1),
                    ("INTELIJIDEA", 2),
                    ("PROGRAMMING", 3),
                    ("STUDYING", 1),
                    ("KNOWLEDGE", 4),
                    ("KOTLIN", 1),
                    ("ANDROID", 1),
                    ("IOS", 1),
                    ("MACOS", 2),
                    ("APPLE", 2),
                    ("DATABASE", 3),
                    ("ALGORITHM", 3),
                    ("DEBUGGING", 3),
                    ("FUNCTION", 2),
                    ("INTERFACE", 3),
                    ("FRAMEWORK", 2),
                    ("DEVELOPMENT", 4),
                    ("REFACTORING", 4),
                    ("COMPILER", 3),
                    ("SYNTAX", 2),
                    ("OOP", 1),
                    ("API", 1),
                    ("VERSION", 2),
                    ("DEBUGGER", 3),
                    ("METHOD", 2),
                    ("LAMBDA", 2),
                    ("INCREMENT", 3),
                    ("MODULE", 2),
                    ("INTERFACE", 3),
                    ("VARIABLE", 3),
                    ("CONSTANT", 3),
                    ("GITHUB", 2),
                    ("COMPONENT", 3),
                    ("DEPENDENCY", 4),
                    ("THREAD", 1),
                    ("STATEMENT", 3),
                    ("COMPILATION", 4),
                    ("SCRIPT", 1),
                    ("APPLICATION", 4),
                    ("MEMORY", 2),
                    ("LOGIC", 2),
                    ("EXCEPTION", 3),
                    ("STACK", 1),
                    ("QUEUE", 1),
                    ("DICTIONARY", 4),
                    ("HASHMAP", 2),
                    ("LINKEDLIST", 4),
                    ("TREE", 1),
                    ("SEARCH", 1),
                    ("SORTING", 2),
                    ("INSERTION", 3),
                    ("BINARY", 2),
                    ("ATTRIBUTE", 3),
                    ("SERVER", 2),
                    ("CLIENT", 2)
                ]

                
                for (text, difficulty) in words {
                    let word = Word(context: context)
                    word.text = text
                    word.difficulty = Int32(difficulty)
                }
                
                try context.save()
            }
        } catch {
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }
    }

    func printAllWords() {
        let context = self.newBackgroundContext()
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        
        do {
            let words = try context.fetch(fetchRequest)
            for word in words {
                print("Word: \(word.text ?? "N/A"), Difficulty: \(word.difficulty)")
            }
        } catch {
            print("Error fetching words:", error.localizedDescription)
        }
    }
}
