//
//  DataStoreHandler.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//

import Foundation

struct DataStoreHandler {
    
    func storeDataset<T: Codable> (dataset: T, endpoint: String, needsEncryption: Bool) {
        do {
            let fileURL = getDocumentDirectory().appendingPathComponent(endpoint)
            let data = try JSONEncoder().encode(dataset)
            try data.write(to: fileURL)
        } catch (let error) {
            print(error)
            fatalError("Something went wrong when we tried to store your data")
        }
    }
    
    func fetchDataset<T: Codable> (datasetEndpoint: String, needsDecryption: Bool) -> T {
        do {
            let fileURL = getDocumentDirectory().appendingPathComponent(datasetEndpoint)
            let data = try Data(contentsOf: fileURL)
            let decodedDataset = try JSONDecoder().decode(T.self, from: data)
            return decodedDataset
        } catch (let error) {
            print(error)
            fatalError("Something went wrong when we tried to retrieve your data")
        }
    }
    
    private func getDocumentDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
