//
//  MovieListViewModel.swift
//  MovieListRXSwift
//
//  Created by Guillaume Bourachot on 15/12/2021.
//

import Foundation
import RxSwift
import RxCocoa
import PromiseKit

protocol MovieListViewModelLogic: AnyObject {
    var movieAPI: MovieAPILogic { get }
    var items: PublishSubject<[Movie]> { get }
    func searchMovie(searchText: String)
    func cancelCurrentSearch()
}

class MovieListViewModel: MovieListViewModelLogic {
    
    // MARK: - Variables
    var movieAPI: MovieAPILogic
    var items = PublishSubject<[Movie]>()
    private var currentSearch: (promise: Promise<MovieSearch>, cancel: () -> Void)?
    
    init(movieAPI: MovieAPILogic) {
        self.movieAPI = movieAPI
    }
    
    func searchMovie(searchText: String) {
        firstly {
            self.movieAPI.searchMovie(searchText: searchText).promise
        }.done { movieSearch in
            if movieSearch.error != nil {
                self.items.onNext([])
            } else if let movies = movieSearch.result?.movies {
                self.items.onNext(movies)
            }            
        }.catch { error in
            self.items.onError(error)
        }
    }
    
    func cancelCurrentSearch() {
        self.currentSearch?.cancel()
    }
}
