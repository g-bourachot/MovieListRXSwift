//
//  MovieAPI.swift
//  MovieListRXSwift
//
//  Created by Guillaume Bourachot on 13/12/2021.
//

import Foundation
import PromiseKit

protocol MovieAPILogic: AnyObject {
    func searchMovie(searchText: String) -> (promise: Promise<MovieSearch>, cancel: () -> Void)
    func searchMovieByTitle(_ title: String) -> (promise: Promise<Movie>, cancel: () -> Void)
    func searchMovieById(_ identifier: String) -> (promise: Promise<Movie>, cancel: () -> Void)
}

class MovieAPI {
    
    static let nilAPIStringValue = "N/A"
    
    //MARK: - Struct and Enums
    struct ErrorApiMessage: Codable {
        let code: String
        let message: String
    }

    enum Error: Swift.Error, CustomStringConvertible {
        case badHTTPStatus(Int, Data)
        case defaultError
        case castError(type: String)
        case apiError(httpStatus: Int, errorApiMessage: ErrorApiMessage)
        case unidentifiedUser

        var description: String {
            switch self {
            case .badHTTPStatus(let code, let data):
                return "Bad HTTP status code \(code), body : \(String(data: data, encoding: .utf8) ?? "")"
            case .apiError(let httpStatus, let errorApiMessage):
                if httpStatus == 404 || httpStatus == 409 {
                    return errorApiMessage.message
                }
                return "API Error : http : \(httpStatus), \(errorApiMessage.message)"
            case .defaultError:
                return "Empty error, shouldn't happen"
            case .unidentifiedUser:
                return "User is not authentified"
            case .castError(let typeString):
                return "Failed to cast object in \(typeString)"
            }
        }
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
    private func dataTask(request: URLRequest) -> Promise<Data> {
        return Promise<Data> { seal in
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data, let response = response as? HTTPURLResponse {
                    if 200...299 ~= response.statusCode {
                        seal.fulfill(data)
                    } else {
                        let apiError: Error? = try? {
                            let errorApiMessage = try JSONDecoder().decode([ErrorApiMessage].self, from: data)
                            return .apiError(httpStatus: response.statusCode, errorApiMessage: errorApiMessage.first!)
                            }()
                        seal.reject(apiError ?? .badHTTPStatus(response.statusCode, data))
                    }
                } else {
                    seal.reject(error ?? Error.defaultError)
                }
            }.resume()
        }
    }

    private func stringTask(request: URLRequest) -> Promise<String> {
        return self.dataTask(request: request).map { data in
            return String(data: data, encoding: .utf8) ?? ""
        }
    }

    private func jsonTask<T: Decodable>(request: URLRequest) -> Promise<T> {
        return self.dataTask(request: request).map { data in
            return try JSONDecoder().decode(T.self, from: data)
        }
    }

    private func jsonTask(request: URLRequest) -> Promise<Void> {
        return self.dataTask(request: request).map { _ in
            return Void()
        }
    }
    
    private func cancellablePromise<T: Decodable>(_ request: URLRequest) -> (promise: Promise<T>, cancel: () -> Void) {
        var urlSessionDataTask: URLSessionDataTask?
        var cancelme = false
        let promise = Promise<T> { seal in
            urlSessionDataTask = urlSession.dataTask(with: request) {(data, response, error) in
                guard !cancelme else {
                    seal.reject(PMKError.cancelled)
                    return
                }
                if let data = data, let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case 200...299:
                        do {
                            seal.fulfill(try JSONDecoder().decode(T.self, from: data))
                        } catch {
                            seal.reject(error)
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
    func searchMovie(searchText: String) -> (promise: Promise<MovieSearch>, cancel: () -> Void) {
        var cancelMethod: () -> Void = { }
        let promise = Promise<MovieSearch> { seal in
            let searchRequest = self.requestBuilder.searchMovie(searchText)
            let searchPromise: (promise: Promise<MovieSearch>, cancel: () -> Void) = self.cancellablePromise(searchRequest)
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
    
    func searchMovieByTitle(_ title: String) -> (promise: Promise<Movie>, cancel: () -> Void) {
        var cancelMethod: () -> Void = { }
        let promise = Promise<Movie> { seal in
            let searchRequest = self.requestBuilder.getMovieByTitle(title)
            let searchPromise: (promise: Promise<Movie>, cancel: () -> Void) = self.cancellablePromise(searchRequest)
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
    func searchMovieById(_ identifier: String) -> (promise: Promise<Movie>, cancel: () -> Void) {
        var cancelMethod: () -> Void = { }
        let promise = Promise<Movie> { seal in
            let searchRequest = self.requestBuilder.getMovieById(identifier)
            let searchPromise: (promise: Promise<Movie>, cancel: () -> Void) = self.cancellablePromise(searchRequest)
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
