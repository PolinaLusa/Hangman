//
//  ContentView.swift
//  Hangman
//
//  Created by Полина Лущевская on 24.06.24.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingNicknameView = false
    @State private var isShowingResults = false
    @State private var nickname = UserDefaults.standard.string(forKey: "nickname") ?? ""
    @State private var gameResults: [GameResult] = UserDefaults.standard.data(forKey: "gameResults").flatMap {
        try? JSONDecoder().decode([GameResult].self, from: $0)
    } ?? []

    @State private var isShowingRulesAlert = false
    @State private var rulesText = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Hangman Game!")
                    .font(.title3)
                    .padding()

                NavigationLink(
                    destination: HangmanGameView(nickname: nickname, gameResults: $gameResults),
                    label: {
                        Text("Start Game")
                            .font(.title2)
                            .padding()
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    })

                Button(action: {
                    isShowingResults = true
                }) {
                    Text("Show Results")
                        .font(.title3)
                        .padding()
                        .background(Color("Mintty"))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
            }
            .padding()
            .fullScreenCover(isPresented: $isShowingNicknameView) {
                NicknameView(nickname: $nickname, isPresented: $isShowingNicknameView)
            }
            .sheet(isPresented: $isShowingResults) {
                ResultsView(gameResults: gameResults)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if let fileUrl = Bundle.main.url(forResource: "Rules", withExtension: "txt") {
                            do {
                                let rulesText = try String(contentsOf: fileUrl)
                                self.rulesText = rulesText
                                self.isShowingRulesAlert = true
                            } catch {
                                print("Error reading rules file:", error.localizedDescription)
                            }
                        } else {
                            print("Rules.txt not found in bundle.")
                        }
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(Color("CustomedGray"))
                            .font(.title2)
                    }
                }
            }
            .onAppear {
                if nickname.isEmpty {
                    isShowingNicknameView = true
                }
            }
            .onDisappear {
                saveGameResults()
            }
            .alert(isPresented: $isShowingRulesAlert) {
                Alert(
                    title: Text("Game Rules"),
                    message: Text(rulesText),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func saveGameResults() {
        do {
            let encodedData = try JSONEncoder().encode(gameResults)
            UserDefaults.standard.set(encodedData, forKey: "gameResults")
        } catch {
            print("Error saving game results:", error.localizedDescription)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
