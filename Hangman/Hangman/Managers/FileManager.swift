//
//  FileManager.swift
//  Hangman
//
//  Created by Полина Лущевская on 24.06.24.
//

import Foundation
import CryptoKit

class FileManager {
    
    static func getResultsFileUrl(encrypted: Bool) throws -> URL {
        let fileName = encrypted ? "Results_encrypted" : "Results_decrypted"
        if let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "txt") {
            return fileUrl
        } else {
            throw NSError(domain: "YourAppDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "\(fileName).txt not found in bundle."])
        }
    }

    static func writeResultToFile(result: String, fileUrl: URL, key: SymmetricKey?) throws {
        let data = Data(result.utf8)
        let dataToWrite: Data
        if let key = key {
            dataToWrite = try CryptoManager.encryptData(data: data, key: key)
        } else {
            dataToWrite = data
        }
        try dataToWrite.write(to: fileUrl)
    }
}
