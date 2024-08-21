//
//  GameResult.swift
//  Hangman
//
//  Created by Полина Лущевская on 25.06.24.
//

import SwiftUI

struct GameResult: Codable, Identifiable{
    let id = UUID()
    let playerName: String
    let timeSpent: Int 
    let mistakesMade: Int
}

struct LeaderboardView: View {
    @State private var records: [GameResult] = [
        GameResult(playerName: "Player1", timeSpent: 120, mistakesMade: 5),
        GameResult(playerName: "Player2", timeSpent: 90, mistakesMade: 2),
        GameResult(playerName: "Player3", timeSpent: 150, mistakesMade: 3)
    ]
    
    var body: some View {
        NavigationView {
            List(records) { record in
                VStack(alignment: .leading) {
                    Text("\(record.playerName)")
                        .font(.headline)
                    Text("Time: \(record.timeSpent) seconds")
                    Text("Mistakes: \(record.mistakesMade)")
                }
            }
            .navigationBarTitle("Leaderboard")
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
