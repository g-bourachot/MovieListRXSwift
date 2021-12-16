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
    var items: PublishSubject<[MovieList.CellModel]> { get }
    func searchMovie(searchText: String)
    func cancelCurrentSearch()
    func displayEmptyCell()
}

class MovieListViewModel: MovieListViewModelLogic {
    
    // MARK: - Variables
    var movieAPI: MovieAPILogic
    var items = PublishSubject<[MovieList.CellModel]>()
    private var currentSearch: (promise: Promise<MovieSearch>, cancel: () -> Void)?
    
    init(movieAPI: MovieAPILogic) {
        self.movieAPI = movieAPI
    }
    
    func displayEmptyCell() {
        self.items.onNext([.empty])
    }
    
    func searchMovie(searchText: String) {
        self.cancelCurrentSearch()
        let search = self.movieAPI.searchMovie(searchText: searchText)
        self.currentSearch = search
        firstly {
            search.promise
        }.done { movieSearch in
            if let error = movieSearch.error {
                self.items.onNext([.error(error)])
            } else {
                let cellModels = movieSearch.movies.map { MovieList.CellModel.movie($0) }
                self.items.onNext(cellModels)
            }            
        }.catch { error in
            self.items.onError(error)
        }.finally {
            self.currentSearch = nil
        }
    }
    
    func cancelCurrentSearch() {
        self.currentSearch?.cancel()
    }
}
