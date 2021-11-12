//
//  KeychainWrapper.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//

import Foundation

struct KeychainWrapper {
    
    func addInternetPassword(server: String, username: String, password: String) throws {
        let password = password.data(using: String.Encoding.utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword, kSecAttrAccount as String: username, kSecAttrServer as String: server, kSecValueData as String: password]
        let status = SecItemAdd(query as CFDictionary, nil)
        print(status)
        guard status == errSecSuccess else { throw KeychainWrapperError.keychainIssue(keychainFeedback: "Keychain error code: \(status)") }
    }
    
    func retrieveInternetPassword(server: String, username: String) throws -> UserLoginModel {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword, kSecAttrServer as String: server, kSecReturnAttributes as String: true, kSecAttrAccount as String: username, kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainWrapperError.noItemFound }
        guard status == errSecSuccess else { throw KeychainWrapperError.keychainIssue(keychainFeedback: "Keychain error code: \(status)") }
        
        guard let existingItem = item as? [String: Any],
              let passwordData = existingItem[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: String.Encoding.utf8),
              let account = existingItem[kSecAttrAccount as String] as? String
        else { throw KeychainWrapperError.keychainIssue(keychainFeedback: "Unknown Error") }
        return UserLoginModel(username: account, pw: password)
    }
    
    func deleteInternetPassword(server: String, username: String) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword, kSecAttrServer as String: server, kSecReturnAttributes as String: true, kSecAttrAccount as String: username, kSecReturnData as String: true]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainWrapperError.keychainIssue(keychainFeedback: "Keychain error code: \(status)") }
    }
}

enum KeychainWrapperError: Error {
    case noItemFound
    case keychainIssue(keychainFeedback: String)
    case itemAlreadyExists
}
