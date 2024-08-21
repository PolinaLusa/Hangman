//
//  NicknameView.swift
//  Hangman
//
//  Created by Полина Лущевская on 25.06.24.
//

import SwiftUI

struct NicknameView: View {
    @Binding var nickname: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text("Enter your nickname")
                .font(.title)
                .padding()
            TextField("Nickname", text: $nickname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                UserDefaults.standard.set(nickname, forKey: "nickname")
                isPresented = false
            }) {
                Text("Start Game")
                    .font(.title2)
                    .padding()
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

#Preview {
    NicknameView(nickname: .constant(""), isPresented: .constant(true))
}
