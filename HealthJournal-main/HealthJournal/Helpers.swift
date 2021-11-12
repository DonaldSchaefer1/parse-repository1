//
//  Helpers.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//

import Foundation

public struct ConfigHandler {
    public func pullConfigValue(key: String) -> Any {
        let dictionary = pullConfigObject()
        guard let configValue = dictionary[key] else {
            fatalError("Failed to find \(key) in config file.")
        }
        return configValue
    }
    
    public func pullConfigValue(key: String, configObject: [String: Any]) -> Any {
        //guard let dictionary = configObject as? [String: Any] else {
        //    fatalError("Failed to access config values.")
        //}
        guard let configValue = configObject[key] else {
            fatalError("Failed to find \(key) in config file.")
        }
        return configValue
    }
    
    public func pullConfigObject() -> [String: Any] {
        let configFile = "PH-Config"
        let fileExtension = "json"
        guard let url = Bundle.main.url(forResource: configFile, withExtension: fileExtension) else {
            fatalError("Failed to load \(configFile) from bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(configFile) from bundle.")
        }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
            fatalError("Failed to load \(configFile) from bundle.")
        }
        guard let dictionary = jsonObject as? [String: Any] else {
            fatalError("Failed to load \(configFile) from bundle.")
        }
        return dictionary
    }
}

struct EntityGenerationResponse: Codable {
    let id: Int
}

struct AlertModel {
    var alertIsPresented = false
    var alertType = ""
    var alertText = "Heads Up"
}

extension Date {
    static func getDatetimeStringInISO8601(datetime: Date) -> String {
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: datetime)
        return dateString
    }
    
    static func getISO8601DatetimeFromString(datetimeString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: datetimeString) ?? Date()
    }
    
    var isWithin24Hours: Bool {
        let numberOfSecondsInDay = Double(60*60*24)
        if (-1*self.timeIntervalSinceNow) < numberOfSecondsInDay {
            print("Seconds since now: \(-1*self.timeIntervalSinceNow)")
            print("Seconds in day: \(numberOfSecondsInDay)")
            return true
        } else {
            print("Seconds since now: \(-1*self.timeIntervalSinceNow)")
            print("Seconds in day: \(numberOfSecondsInDay)")
            return false
        }
    }
}

enum DataServiceError: Error, Equatable {
    case entityAlreadyExistsInDataStore
    case networkingError
    case remoteDataStoreError(_ description: String)
    case localDataStoreError(_ description: String)
    //case keychainError // not in use yet
}
