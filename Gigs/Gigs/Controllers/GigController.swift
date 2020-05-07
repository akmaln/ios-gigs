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
        case noData, failedSignUP, failedLogIn, noToken, tryAgain
    }
    
    var bearer: Bearer?
    private let baseURL = URL(string: "https://lambdagigapi.herokuapp.com/api")!
    private lazy var signUpURL = baseURL.appendingPathComponent("/users/signup")
    private lazy var logInURL = baseURL.appendingPathComponent("/users/login")
    private lazy var allGigsURL = baseURL.appendingPathComponent("/gigs/")
    
    private lazy var jsonEncoder = JSONEncoder()
    private lazy var jsonDecoder = JSONDecoder()
    var gigs: [Gig] = []
    
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
    
    func logIn(with user: User, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        print("signUpURL = \(logInURL.absoluteString)")
        
        var request = URLRequest(url: logInURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("log in failed with error: \(error)")
                    completion(.failure(.failedLogIn))
                    return
                }
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200 else {
                        print("log in was unsuccessful")
                        completion(.failure(.failedLogIn))
                        return
                }
                guard let data = data else {
                    print("no data recieved during sign in.")
                    completion(.failure(.noData))
                    return
                }
                do {
                    self.bearer = try self.jsonDecoder.decode(Bearer.self, from: data)
                } catch {
                    print("error decoding bearer object: \(error)")
                    completion(.failure(.noToken))
                }
                
                completion(.success(true))
            }
            task.resume()
        } catch {
            print("error encoding user: \(error)")
            completion(.failure(.failedLogIn))
        }
    }
    
    func getAllGigs(completion: @escaping (Result<[Gig], NetworkError>) -> Void) {
        guard let bearer = bearer else {
            completion(.failure(.noToken))
            return
        }
        
        
        var request = URLRequest(url: allGigsURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("error recieving gigs data: \(error)")
                completion(.failure(.tryAgain))
            }
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.noToken))
            }
            guard let data = data else {
                print("no data recieved from getAllGigs")
                completion(.failure(.noData))
                return
            }
            do {
                self.jsonDecoder.dateDecodingStrategy = .iso8601
                let gigs = try self.jsonDecoder.decode([Gig].self, from: data)
                self.gigs = gigs
                completion(.success(gigs))
            } catch {
                print("error decoding gig name data: \(error)")
                completion(.failure(.tryAgain))
            }
        }
        task.resume()
    }
    
    func createGig(with gig: Gig, completion: @escaping (Result<Gig, NetworkError>) -> Void) {
        guard let bearer = bearer else {
            completion(.failure(.noToken))
            return
        }

        var request = URLRequest(url: allGigsURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
       
        
        jsonEncoder.dateEncodingStrategy = .iso8601
        
        do {
            let newGig = try jsonEncoder.encode(gig)
            request.httpBody = newGig
        } catch {
            print("Error encoding new gig: \(error)")
            completion(.failure(.tryAgain))
            return
        }

            let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let error = error {
                print("Error creating gig: \(error)")
                completion(.failure(.noData))
                return
            }

            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                print("Got response status code \(response.statusCode) while creating a gig")
                completion(.failure(.noData))
                return
            }
            self.gigs.append(gig)
            completion(.success(gig))
            
        }
        task.resume()
    }

}
