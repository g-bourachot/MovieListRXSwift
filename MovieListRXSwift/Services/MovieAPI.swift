//
//  MovieAPI.swift
//  MovieListRXSwift
//
//  Created by Guillaume Bourachot on 13/12/2021.
//

import Foundation
import PromiseKit

protocol MovieAPILogic: AnyObject {
    func searchMovie(searchText: String) -> (promise: Promise<(result: MovieSearch?, error: MovieSearchError?)>, cancel: () -> Void)
    func searchMovieByTitle(_ title: String) -> (promise: Promise<(result: Movie?, error: MovieSearchError?)>, cancel: () -> Void)
    func searchMovieById(_ identifier: String) -> (promise: Promise<(result: Movie?, error: MovieSearchError?)>, cancel: () -> Void)
}

class MovieAPI {
    
    static let nilAPIStringValue = "N/A"
    
    //MARK: - Struct and Enums
    enum Error: Swift.Error {
        case defaultError
    }
    
    // MARK: - Singleton
    static let shared: MovieAPILogic = MovieAPI(requestBuilder: MovieAPIRequestBuilder.production)
    
    // MARK: - Variables
    let requestBuilder: MovieAPIRequestBuilder
    let urlSession: URLSession
    
    //MARK: - Initializers
    public init(requestBuilder: MovieAPIRequestBuilder) {
        self.requestBuilder = requestBuilder
        self.urlSession = URLSession.shared
    }
    
    //MARK: - Private functions
    private func cancellablePromise<T: Decodable>(_ request: URLRequest) -> (promise: Promise<(result: T?, error: MovieSearchError?)>, cancel: () -> Void) {
        var urlSessionDataTask: URLSessionDataTask?
        var cancelme = false
        let promise = Promise<(result: T?, error: MovieSearchError?)> { seal in
            urlSessionDataTask = urlSession.dataTask(with: request) {(data, response, error) in
                guard !cancelme else {
                    seal.reject(PMKError.cancelled)
                    return
                }
                if let data = data, let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case 200...299:
                        do {
                            let decodedData = try JSONDecoder().decode(T.self, from: data)
                            seal.fulfill((result: decodedData, error: nil))
                        } catch {
                            if let movieSearchError = try? JSONDecoder().decode(MovieSearchError.self, from: data) {
                                seal.fulfill((result: nil, error: movieSearchError))
                            } else {
                                seal.reject(error)
                            }
                        }
                    default:
                        seal.reject(Error.defaultError)
                    }
                } else {
                    seal.reject(Error.defaultError)
                }
            }
            urlSessionDataTask!.resume()
        }
        let cancel = {
            cancelme = true
            urlSessionDataTask?.cancel()
        }
        return (promise: promise, cancel: cancel)
    }
}

extension MovieAPI: MovieAPILogic {
    func searchMovie(searchText: String) -> (promise: Promise<(result: MovieSearch?, error: MovieSearchError?)>, cancel: () -> Void) {
        var cancelMethod: () -> Void = { }
        let promise = Promise<(result: MovieSearch?, error: MovieSearchError?)> { seal in
            let searchRequest = self.requestBuilder.searchMovie(searchText)
            let searchPromise: (promise: Promise<(result: MovieSearch?, error: MovieSearchError?)>, cancel: () -> Void) = self.cancellablePromise(searchRequest)
            cancelMethod = searchPromise.cancel
            firstly {
                searchPromise.promise
            }.done { result in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
        return (promise, cancelMethod)
    }
    
    func searchMovieByTitle(_ title: String) -> (promise: Promise<(result: Movie?, error: MovieSearchError?)>, cancel: () -> Void) {
        var cancelMethod: () -> Void = { }
        let promise = Promise<(result: Movie?, error: MovieSearchError?)> { seal in
            let searchRequest = self.requestBuilder.getMovieByTitle(title)
            let searchPromise: (promise: Promise<(result: Movie?, error: MovieSearchError?)>, cancel: () -> Void) = self.cancellablePromise(searchRequest)
            cancelMethod = searchPromise.cancel
            firstly {
                searchPromise.promise
            }.done { result in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
        return (promise, cancelMethod)
    }
    func searchMovieById(_ identifier: String) -> (promise: Promise<(result: Movie?, error: MovieSearchError?)>, cancel: () -> Void) {
        var cancelMethod: () -> Void = { }
        let promise = Promise<(result: Movie?, error: MovieSearchError?)> { seal in
            let searchRequest = self.requestBuilder.getMovieById(identifier)
            let searchPromise: (promise: Promise<(result: Movie?, error: MovieSearchError?)>, cancel: () -> Void) = self.cancellablePromise(searchRequest)
            cancelMethod = searchPromise.cancel
            firstly {
                searchPromise.promise
            }.done { result in
                seal.fulfill(result)
            }.catch { error in
                seal.reject(error)
            }
        }
        return (promise, cancelMethod)
    }
}
