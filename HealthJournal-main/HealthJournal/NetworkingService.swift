//
//  NetworkingService.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//

import Foundation

enum NetworkingServiceError: Error {
    case ApplicationError(_ errorText: String)
    case GenericNetworkServiceError
}

struct PHSErrorResponse: Decodable {
    let error: String
}

protocol NetworkingService {
    func send<T:Decodable, H:Encodable>(requestProvider: URLRequestProviding, dataset: H, completion: @escaping (Result<T, NetworkingServiceError>) -> Void)
    func execute<T:Decodable>(requestProvider: URLRequestProviding, completion: @escaping (Result<T, NetworkingServiceError>) -> Void)
}

extension NetworkingService {
    func send<H:Encodable, T: Decodable>(requestProvider: URLRequestProviding, dataset: H, completion: @escaping (Result<T, NetworkingServiceError>) -> Void) {
        let urlRequest = requestProvider.urlRequest
        let session = makeURLSession()
        guard let data: Data = convertDatasetToData(dataset) else {
            print("Unexpected error with dataset serialization.")
            return
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        session.uploadTask(with: urlRequest, from: data) { data, response, error in
            
            if let error = error {
                //PHLogger().log(errorObject: error)
                DispatchQueue.main.async {
                    completion(.failure(NetworkingServiceError.GenericNetworkServiceError))
                    return
                }
            }
            guard let data = data else {
                preconditionFailure("There was no error but there is also no data.")
            }
            if let decodedObject = try? decoder.decode(PHSErrorResponse.self, from: data) {
                //PHLogger().log(errorString: decodedObject.error)
                DispatchQueue.main.async {
                    completion(.failure(NetworkingServiceError.ApplicationError(decodedObject.error)))
                    return
                }
            }
            do {
                let decodedObject = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedObject))
                    return
                }

            } catch {
                //PHLogger().log(errorObject: error)
                DispatchQueue.main.async {
                    completion(.failure(NetworkingServiceError.GenericNetworkServiceError))
                    return
                }

            }
        }.resume()
    }
    
    func execute<T:Decodable>(requestProvider: URLRequestProviding, completion: @escaping (Result<T, NetworkingServiceError>) -> Void) {
        let urlRequest = requestProvider.urlRequest
        let session = makeURLSession()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                //PHLogger().log(errorObject: error)
                DispatchQueue.main.async {
                    completion(.failure(NetworkingServiceError.GenericNetworkServiceError))
                    return
                }

            }
            guard let data = data else {
                preconditionFailure("There was no error but there is also no data.")
            }
            if let decodedObject = try? decoder.decode(PHSErrorResponse.self, from: data) {
                //PHLogger().log(errorString: decodedObject.error)
                DispatchQueue.main.async {
                    completion(.failure(NetworkingServiceError.ApplicationError(decodedObject.error)))
                    return
                }
            }
            do {
                let decodedObject = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedObject))
                    return
                }

            } catch {
                //PHLogger().log(errorObject: error)
                DispatchQueue.main.async {
                    completion(.failure(NetworkingServiceError.GenericNetworkServiceError))
                    return
                }

            }
        }.resume()
    }
    
    func makeURLSession() -> URLSession {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        return session
    }
    
    func convertDatasetToData<T: Encodable>(_ dataset: T) -> Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let uploadData = try? encoder.encode(dataset) else {
            return nil
        }
        return uploadData
    }
}

struct BasicNetworkService: NetworkingService {
/// Instantiation of a NetworkingService.
/// All functionality is defined in NetworkingService extension.
}


protocol URLRequestProviding {
    var urlRequest: URLRequest { get }
}


enum Endpoint {
    case register
    case registration(userId: Int)
    case newMeal
    case deleteMeal(mealId: String)
    case meals(filterByUserId: Int)
}

extension Endpoint: URLRequestProviding {
    var urlRequest: URLRequest {
        let configHandler = ConfigHandler()
        let configObject = configHandler.pullConfigObject()
        let host = configHandler.pullConfigValue(key: "PHS_HOST_ADDRESS", configObject: configObject) as! String
        let port = configHandler.pullConfigValue(key: "PHS_PORT", configObject: configObject) as! Int
        let scheme = configHandler.pullConfigValue(key: "PHS_SCHEME", configObject: configObject) as! String
        let apiVersion = configHandler.pullConfigValue(key: "PHS_API_VERSION", configObject: configObject) as! String
        let basePath = "/api" + apiVersion
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port

        switch self {
        case .register:
            let endpoint = configHandler.pullConfigValue(key: "PHS_REGISTRATION_ENDPOINT", configObject: configObject) as! String
            let path = basePath + endpoint
            urlComponents.path = path
            let url = urlComponents.url!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return request
        case .newMeal:
            let endpoint = "/meal" // PLACEHOLDER
            let path = basePath + endpoint
            urlComponents.path = path
            let url = urlComponents.url!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return request
        case .meals (let userId):
            let endpoint = "meals" // PLACEHOLDER
            let path = basePath + endpoint
            urlComponents.query = "user_id=\(userId)"
            urlComponents.path = path
            let url = urlComponents.url!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            return request
        case .registration(let userId):
            let endpoint = "/user/accountinfo" // PLACEHOLDER
            let path = basePath + endpoint
            urlComponents.query = "user_id=\(userId)"
            urlComponents.path = path
            let url = urlComponents.url!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            return request
        case .deleteMeal(let mealId):
            let endpoint = "/meal" // PLACEHOLDER
            let path = basePath + endpoint
            urlComponents.query = "meal_id=\(mealId)"
            urlComponents.path = path
            let url = urlComponents.url!
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            return request
        }
    }
}
