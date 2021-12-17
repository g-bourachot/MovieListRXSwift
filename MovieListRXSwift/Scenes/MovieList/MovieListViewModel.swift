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
    func setDelegate(to object: MovieListViewModelDelegate)
    func searchMovie(searchText: String)
    func cancelCurrentSearch()
    func displayEmptyCell()
}

protocol MovieListViewModelDelegate: AnyObject {
    func showLoader(_: Bool)
}

class MovieListViewModel: MovieListViewModelLogic {
    
    // MARK: - Variables
    var movieAPI: MovieAPILogic
    var items = PublishSubject<[MovieList.CellModel]>()
    weak var delegate: MovieListViewModelDelegate?
    private var currentSearch: (promise: Promise<MovieSearch>, cancel: () -> Void)?
    
    init(movieAPI: MovieAPILogic) {
        self.movieAPI = movieAPI
    }
    
    func setDelegate(to object: MovieListViewModelDelegate) {
        self.delegate = object
    }
    
    func displayEmptyCell() {
        self.items.onNext([.empty])
    }
    
    func searchMovie(searchText: String) {
        self.delegate?.showLoader(true)
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
            self.delegate?.showLoader(false)
            self.currentSearch = nil
        }
    }
    
    func cancelCurrentSearch() {
        self.currentSearch?.cancel()
    }
}
