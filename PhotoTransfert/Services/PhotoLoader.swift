//
//  File.swift
//  PhotoTransfert
//
//  Created by Luigi Aiello on 28/10/22.
//

import Foundation
import GoogleSignIn
import Combine

/// An observable class to load the current user's birthday.
final class PhotoLoader: ObservableObject {
    
    // MARK: - Stored Properties
    
    /// The scope required to read a user's birthday.
    static let photoReadScopes = ["https://www.googleapis.com/auth/photoslibrary", "https://www.googleapis.com/auth/photoslibrary.edit.appcreateddata", "https://www.googleapis.com/auth/photoslibrary.sharing"]
    private let baseUrlString = "https://photoslibrary.googleapis.com/v1/mediaItems"
    private let personFieldsQuery = URLQueryItem(name: "pageSize", value: "100")
    private let mediaSubject = PassthroughSubject<[Photo], Error>()
    
    // MARK: - Lazy Properties
    
    private lazy var components: URLComponents? = {
        var comps = URLComponents(string: baseUrlString)
        comps?.queryItems = [personFieldsQuery]
        return comps
    }()
    
    private lazy var request: URLRequest? = {
        guard let components = components, let url = components.url else {
            return nil
        }
        return URLRequest(url: url)
    }()
    
    private lazy var session: URLSession? = {
        guard let accessToken = GIDSignIn
            .sharedInstance
            .currentUser?
            .authentication
            .accessToken else { return nil }
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        return URLSession(configuration: configuration)
    }()
    
    // MARK: - Methods
    
    private func sessionWithFreshToken(completion: @escaping (Result<URLSession, Error>) -> Void) {
        let authentication = GIDSignIn.sharedInstance.currentUser?.authentication
        authentication?.do { auth, error in
            guard let token = auth?.accessToken else {
                completion(.failure(.couldNotCreateURLSession(error)))
                return
            }
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(token)"
            ]
            let session = URLSession(configuration: configuration)
            completion(.success(session))
        }
    }
    
    /// Creates a `Publisher` to fetch a user's `Birthday`.
    /// - parameter completion: A closure passing back the `AnyPublisher<Birthday, Error>`
    /// upon success.
    /// - note: The `AnyPublisher` passed back through the `completion` closure is created with a
    /// fresh token. See `sessionWithFreshToken(completion:)` for more details.
    func photoPublisher(pageToken: String?, completion: @escaping (AnyPublisher<PhotoResponse, Error>) -> Void) {
        guard var comps = URLComponents(string: baseUrlString) else {
            return
        }
        
        let pageToken = URLQueryItem(name: "pageToken", value: pageToken ?? "")
        comps.queryItems = [personFieldsQuery, pageToken]
        
        guard let url = comps.url else {
            return
        }
        
        let request = URLRequest(url: url)
        
        sessionWithFreshToken { result in
            switch result {
            case .success(let authSession):
                let phPublisher = authSession.dataTaskPublisher(for: request)
                    .tryMap { data, error -> PhotoResponse in
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(PhotoResponse.self, from: data)
                        
                        return response
                    }
                    .mapError { error -> Error in
                        guard let loaderError = error as? Error else {
                            return Error.couldNotFetchPhotos(underlying: error)
                        }
                        return loaderError
                    }
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
                
                completion(phPublisher)
            case .failure(let error):
                completion(Fail(error: error).eraseToAnyPublisher())
            }
        }
    }
    
    func downloadPhoto(url: URL, completion: @escaping (AnyPublisher<Data, Error>) -> Void) {
        sessionWithFreshToken { result in
            switch result {
            case .success(let authSession):
                let request = URLRequest(url: url)
                let phPublisher = authSession.dataTaskPublisher(for: request)
                    .tryMap { data, error -> Data in
                        return data
                    }
                    .mapError { error -> Error in
                        guard let loaderError = error as? Error else {
                            return Error.couldNotFetchPhotos(underlying: error)
                        }
                        return loaderError
                    }
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
                
                completion(phPublisher)
            case .failure(let error):
                completion(Fail(error: error).eraseToAnyPublisher())
            }
        }
    }
}

extension PhotoLoader {
    /// An error representing what went wrong in fetching a user's number of day until their birthday.
    enum Error: Swift.Error {
        case couldNotCreateURLSession(Swift.Error?)
        case couldNotCreateURLRequest
        case userHasNoBirthday
        case couldNotFetchPhotos(underlying: Swift.Error)
    }
}
