//
//  CryptoManager.swift
//  Hangman
//
//  Created by Полина Лущевская on 24.06.24.
//

import Foundation
import CryptoKit

struct CryptoManager {
    static func encryptData(data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }
}

