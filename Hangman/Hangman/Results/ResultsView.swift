//
//  ResultsView.swift
//  Hangman
//
//  Created by Полина Лущевская on 25.06.24.
//

import SwiftUI

struct ResultsView: View {
    @State private var sortedBy: SortOption = .playerName
    @State private var sortAscending = true
    
    var gameResults: [GameResult]
    
    enum SortOption {
        case playerName
        case timeSpent
        case mistakesMade
    }
    
    var sortedResults: [GameResult] {
        switch sortedBy {
        case .playerName:
            return gameResults.sorted {
                if $0.playerName == $1.playerName {
                    return sortAscending ? $0.timeSpent < $1.timeSpent : $0.timeSpent > $1.timeSpent
                } else {
                    return sortAscending ? $0.playerName < $1.playerName : $0.playerName > $1.playerName
                }
            }
        case .timeSpent:
            return sortAscending ? gameResults.sorted(by: { $0.timeSpent < $1.timeSpent }) : gameResults.sorted(by: { $0.timeSpent > $1.timeSpent })
        case .mistakesMade:
            return sortAscending ? gameResults.sorted(by: { $0.mistakesMade < $1.mistakesMade }) : gameResults.sorted(by: { $0.mistakesMade > $1.mistakesMade })
        }
    }

    
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedResults) { result in
                    VStack(alignment: .leading) {
                        Text("Player: \(result.playerName)")
                        Text("Time Left: \(result.timeSpent) seconds")
                        Text("Mistakes Made: \(result.mistakesMade)")
                    }
                }
            }
            .navigationTitle("Game Results")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            sortedBy = .playerName
                        }) {
                            Text("Player Name")
                            Image(systemName: sortedBy == .playerName ? (sortAscending ? "arrow.up" : "arrow.down") : "")
                        }
                        Button(action: {
                            sortedBy = .timeSpent
                        }) {
                            Text("Time Spent")
                            Image(systemName: sortedBy == .timeSpent ? (sortAscending ? "arrow.up" : "arrow.down") : "")
                        }
                        Button(action: {
                            sortedBy = .mistakesMade
                        }) {
                            Text("Mistakes Made")
                            Image(systemName: sortedBy == .mistakesMade ? (sortAscending ? "arrow.up" : "arrow.down") : "")
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
        }
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        let gameResults: [GameResult] = [
            GameResult(playerName: "Player1", timeSpent: 30, mistakesMade: 3),
            GameResult(playerName: "Player2", timeSpent: 45, mistakesMade: 5),
            GameResult(playerName: "Player3", timeSpent: 60, mistakesMade: 2)
        ]
        
        return ResultsView(gameResults: gameResults)
    }
}
