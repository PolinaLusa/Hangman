//
//  HangmanGameView.swift
//  Hangman
//
//  Created by Полина Лущевская on 24.06.24.
//

import SwiftUI
import CoreData
import CryptoKit

struct HangmanGameView: View {
    @Environment(\.presentationMode) var presentationMode
    
    private var nickname: String
    @Binding var gameResults: [GameResult]
    
    @State private var wordToGuess = ""
    @State private var guessedLetters = [String]()
    @State private var incorrectGuesses = 0
    @State private var gameStatusMessage = "Guess the word!"
    @State private var isShowingRulesAlert = false
    @State private var rulesText: String = ""
    @State private var timeRemaining = 300
    @State private var timer: Timer? = nil
    @State private var isGameActive = true
    @State private var isTimerPaused = false
    @State private var savedTimeRemaining: Int?
    
    private var maxIncorrectGuesses = 8
    private let encryptionKey = SymmetricKey(size: .bits256)
  
    private let persistentContainer = PersistentContainer.shared
    
    init(nickname: String, gameResults: Binding<[GameResult]>) {
        self.nickname = nickname
        self._gameResults = gameResults
    }
    
    private var formattedWord: String {
        var displayWord = ""
        for letter in wordToGuess {
            if guessedLetters.contains(String(letter)) {
                displayWord += "\(letter)"
            } else {
                displayWord += " _ "
            }
        }
        return displayWord
    }
    
    private var remainingAttempts: Int {
        return maxIncorrectGuesses - incorrectGuesses
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Remaining attempts: \(remainingAttempts)")
                .font(.title)
            Text("Time remaining: \(timeRemaining) seconds")
                .font(.title2)
            Text(formattedWord)
                .font(.largeTitle)
                .padding()
            Text(gameStatusMessage)
                .font(.headline)
                .padding()
            hangmanImage()
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .padding()
            VStack {
                ForEach(0..<3) { row in
                    HStack {
                        ForEach(0..<9) { column in
                            let letterIndex = row * 9 + column
                            if letterIndex < 26 {
                                let letter = String(UnicodeScalar(letterIndex + 65)!)
                                Button(action: {
                                    guess(letter: letter)
                                }) {
                                    Text(letter)
                                        .font(.title2)
                                        .frame(width: 30, height: 30)
                                        .background(guessedLetters.contains(letter) ? Color("CustomedGray") : Color("LightPink"))
                                        .foregroundColor(.white)
                                        .cornerRadius(3)
                                }
                                .disabled(guessedLetters.contains(letter) || remainingAttempts == 0 || !isGameActive)
                            }
                        }
                    }
                }
            }
            .padding()
            Button(action: resetGame) {
                Text("New Game")
                    .font(.title2)
                    .padding()
                    .background(Color("Mintty"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if let fileUrl = Bundle.main.url(forResource: "Rules", withExtension: "txt") {
                        do {
                            let resultsFilePath = fileUrl.path
                            print("Path to Rules.txt: \(resultsFilePath)")
                            let rulesText = try String(contentsOf: fileUrl)
                            self.rulesText = rulesText
                            self.isShowingRulesAlert = true
                            self.isTimerPaused = true
                            self.savedTimeRemaining = self.timeRemaining
                            self.timer?.invalidate()
                        } catch {
                            print("Error reading results file:", error.localizedDescription)
                        }
                    } else {
                        print("Results.txt not found in bundle.")
                    }
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(Color("CustomedGray"))
                        .font(.title2)
                }
            }
        }
        .alert(isPresented: $isShowingRulesAlert) {
                   Alert(
                       title: Text("Hangman Results"),
                       message: Text(rulesText),
                       dismissButton: .default(Text("OK")) {
                           if isTimerPaused {
                               resumeTimer()
                               isTimerPaused = false
                           }
                       }
                   )
               }
        .onAppear {
            startTimer()
            persistentContainer.fetchRandomWord { word in
                DispatchQueue.main.async {
                    if let word = word {
                        self.wordToGuess = word
                        self.logMessage("New word fetched for reset: \(self.wordToGuess)")
                    } else {
                        self.wordToGuess = "DEFAULT"
                        self.logMessage("No words found, setting default word")
                    }
                }
            }
        }
        .onChange(of: formattedWord) { newFormattedWord in
            checkGameStatus()
        }
    }
    
    private func guess(letter: String) {
        guessedLetters.append(letter)
        if wordToGuess.contains(letter) {
            checkWin()
        } else {
            incorrectGuesses += 1
            checkLose()
        }
    }
    
    private func logMessage(_ message: String) {
        print("[DEBUG] \(message)")
    }
    
    private func resetGame() {
        guessedLetters.removeAll()
        incorrectGuesses = 0
        gameStatusMessage = "Guess the word!"
        timeRemaining = 300
        isGameActive = true
        
        persistentContainer.fetchRandomWord { word in
            DispatchQueue.main.async {
                if let word = word {
                    self.wordToGuess = word
                    self.logMessage("New word fetched for reset: \(self.wordToGuess)")
                } else {
                    self.wordToGuess = "DEFAULT"
                    self.logMessage("No words found, setting default word")
                }
            }
        }
        
        startTimer()
    }

    private func checkWin() {
        if !formattedWord.contains("_") {
            let result = "You won! The word was \(wordToGuess)."
            let gameResult = GameResult(playerName: nickname, timeSpent: timeRemaining, mistakesMade: incorrectGuesses)
            gameResults.append(gameResult)
            do {
                let encryptedFileUrl = try FileManager.getResultsFileUrl(encrypted: true)
                let decryptedFileUrl = try FileManager.getResultsFileUrl(encrypted: false)
                try FileManager.writeResultToFile(result: result, fileUrl: encryptedFileUrl, key: encryptionKey)
                try FileManager.writeResultToFile(result: result, fileUrl: decryptedFileUrl, key: nil)
                gameStatusMessage = result
                logMessage("Winning result saved to \(encryptedFileUrl) and \(decryptedFileUrl)")
                isGameActive = false
                timer?.invalidate()
            } catch {
                print("Error writing result to file:", error.localizedDescription)
                logMessage("Error writing winning result: \(error.localizedDescription)")
            }
        }
    }
    
    private func checkLose() {
        if remainingAttempts == 0 {
            let result = "You lost! The word was \(wordToGuess)."
            let gameResult = GameResult(playerName: nickname, timeSpent: timeRemaining, mistakesMade: incorrectGuesses)
            gameResults.append(gameResult)
            do {
                let encryptedFileUrl = try FileManager.getResultsFileUrl(encrypted: true)
                let decryptedFileUrl = try FileManager.getResultsFileUrl(encrypted: false)
                try FileManager.writeResultToFile(result: result, fileUrl: encryptedFileUrl, key: encryptionKey)
                try FileManager.writeResultToFile(result: result, fileUrl: decryptedFileUrl, key: nil)
                gameStatusMessage = result
                logMessage("Losing result saved to \(encryptedFileUrl) and \(decryptedFileUrl)")
                isGameActive = false
                timer?.invalidate()
            } catch {
                print("Error writing result to file:", error.localizedDescription)
                logMessage("Error writing losing result: \(error.localizedDescription)")
            }
        }
    }
    
    private func hangmanImage() -> Image {
        HangmanImage.getImage(for: incorrectGuesses)
    }

    
    private func startTimer() {
        timer?.invalidate()
        
        if let savedTimeRemaining = savedTimeRemaining {
            timeRemaining = savedTimeRemaining
            self.savedTimeRemaining = nil
        } else {
            timeRemaining = 300
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timer?.invalidate()
                self.checkLoseDueToTimeout()
            }
        }
    }

    
    private func resumeTimer() {
        if let savedTimeRemaining = savedTimeRemaining {
            timeRemaining = savedTimeRemaining
            self.savedTimeRemaining = nil
        }
        startTimer()
    }
    
    private func checkLoseDueToTimeout() {
            if isGameActive {
                let encryptedFileUrl: URL
                let decryptedFileUrl: URL
                do {
                    encryptedFileUrl = try FileManager.getResultsFileUrl(encrypted: true)
                    decryptedFileUrl = try FileManager.getResultsFileUrl(encrypted: false)
                    let result = "Time's up! You lost! The word was \(wordToGuess)."
                    try FileManager.writeResultToFile(result: result, fileUrl: encryptedFileUrl, key: encryptionKey)
                    try FileManager.writeResultToFile(result: result, fileUrl: decryptedFileUrl, key: nil)
                    gameStatusMessage = "Time's up! You lost!"
                    logMessage("Time's up! You lost! Result saved to \(encryptedFileUrl) and \(decryptedFileUrl)")
                    self.savedTimeRemaining = self.timeRemaining
                } catch {
                    print("Error writing result to file:", error.localizedDescription)
                    logMessage("Error writing timeout result: \(error.localizedDescription)")
                }
                isGameActive = false
            }
        }
    
    private func checkGameStatus() {
        if !formattedWord.contains("_") {
            gameStatusMessage = "You won! The word was \(wordToGuess)."
            isGameActive = false
            timer?.invalidate()
        } else if remainingAttempts == 0 {
            gameStatusMessage = "You lost! The word was \(wordToGuess)."
            isGameActive = false
            timer?.invalidate()
        }
    }
}

struct HangmanGameView_Previews: PreviewProvider {
    @State static var gameResults: [GameResult] = []

    static var previews: some View {
        HangmanGameView(nickname: "Polina", gameResults: $gameResults)
    }
}
