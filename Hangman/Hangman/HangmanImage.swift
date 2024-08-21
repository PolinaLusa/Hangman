//
//  HangmanImage.swift
//  Hangman
//
//  Created by Полина Лущевская on 25.06.24.
//

import SwiftUI

public struct HangmanImage {
    public static func getImage(for incorrectGuesses: Int) -> Image {
        let imageName: String
        switch incorrectGuesses {
        case 1:
            imageName = "Hangman1"
        case 2:
            imageName = "Hangman2"
        case 3:
            imageName = "Hangman3"
        case 4:
            imageName = "Hangman4"
        case 5:
            imageName = "Hangman5"
        case 6:
            imageName = "Hangman6"
        case 7:
            imageName = "Hangman7"
        case 8:
            imageName = "Hangman8"
        default:
            imageName = "Hangman0"
        }
        return Image(imageName)
    }
}
