//
//  Models.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//

import Foundation

struct UserAccountModel: Codable {
    var userId: Int?
    var firstName = ""
    var lastName = ""
    var email = ""
    var sex = ""
    var dateOfBirth = Date()
    var username = ""
    var pw = ""
    
    var dobText : String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let dateString = dateFormatter.string(from: dateOfBirth)
        return dateString
    }
}

struct UserLoginModel: Codable {
    var username = ""
    var pw = ""
}
