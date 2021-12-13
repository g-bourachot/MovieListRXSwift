//
//  MovieAPIRequestBuilder.swift
//  MovieListRXSwift
//
//  Created by Guillaume Bourachot on 13/12/2021.
//

import Foundation

class MovieAPIRequestBuilder {

    //MARK: - Variables
    var baseURLString: String
    let baseURLComponents: URLComponents
    var baseURL: URL {
        if let url = URL(string: self.baseURLString) {
            return url
        } else {
            fatalError()
        }
    }
    
    //MARK: - Initilizers
    public init(baseURLString: String) {
        self.baseURLString = baseURLString
        self.baseURLComponents = URLComponents(url: URL(string: baseURLString)!, resolvingAgainstBaseURL: true)!
    }
    
    //MARK: - Public requests
    public func getMovieById(_ identifier: String) -> URLRequest {
        var urlComponents = self.baseURLComponents
        let queryItems = [
            URLQueryItem(name: "i", value: identifier),
            URLQueryItem(name: "apikey", value: Self.apiKey)
        ]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url!.appendingPathComponent("schools/search")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
