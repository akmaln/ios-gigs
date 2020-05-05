//
//  GigController.swift
//  Gigs
//
//  Created by Akmal Nurmatov on 5/5/20.
//  Copyright © 2020 Akmal Nurmatov. All rights reserved.
//

import Foundation

class GigController {
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }

    enum NetworkError: Error {
        case noData, failedSignUP
    }
    
    var bearer: Bearer?
    private let baseURL = URL(string: "https://lambdagigapi.herokuapp.com/api")!
    private lazy var signUpURL = baseURL.appendingPathComponent("/users/signup")
    private lazy var logInURL = baseURL.appendingPathComponent("/users/login")
    
    private lazy var jsonEncoder = JSONEncoder()
    
    func signUp(with user: User, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        print("signUpURL = \(signUpURL.absoluteString)")
        
        var request = URLRequest(url: signUpURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
                if let error = error {
                    print("signup failed with error: \(error)")
                    completion(.failure(.failedSignUP))
                    return
                }
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200 else {
                        print("signup was unsuccessful")
                        completion(.failure(.failedSignUP))
                        return
                }
                completion(.success(true))
            }
            task.resume()
        } catch {
            print("error encoding user: \(error)")
            completion(.failure(.failedSignUP))
        }
    }
}

