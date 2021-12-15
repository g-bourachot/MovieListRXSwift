//
//  MovieListViewController.swift
//  360MedicsTestProject
//
//  Created by Guillaume Bourachot on 13/12/2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol MovieListDisplayLogic: AnyObject {
    func searchMovies(searchText: String)
}

class MovieListViewController: UIViewController {
    
    // MARK: - Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(nibName: "MovieListView", bundle: nil)
        setup()
    }
    
    // MARK: - Setup
    private func setup() {
        
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var uiSearchBar: UISearchBar!
    
    // MARK: - Variables
    private let bag = DisposeBag()
    private let viewModel: MovieListViewModelLogic = MovieListViewModel(movieAPI: MovieAPI.shared)
    private let throttleIntervalInMilliseconds = 100
    
    // MARK: - Overrided functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rx.setDelegate(self).disposed(by: bag)
        bindTableView()
        self.setupSearchChangeHandling()
    }
    
    private func bindTableView() {
        tableView.register(UINib(nibName: "MovieListTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieListTableViewCell")
        viewModel.items.bind(to: tableView
                                .rx
                                .items(cellIdentifier: "MovieListTableViewCell",
                                       cellType: MovieListTableViewCell.self)) { (row,item,cell) in
            cell.configureCell(with: item)
        }.disposed(by: bag)
        
        tableView.rx.modelSelected(Movie.self).subscribe(onNext: { movie in
            print("SelectedItem: \(movie.title)")
        }).disposed(by: bag)
    }
    
    private func setupSearchChangeHandling() {
        uiSearchBar
            .rx.text // Observable property thanks to RxCocoa
            .orEmpty // Make it non-optional
            .observe(on: MainScheduler.asyncInstance)
            .throttle(.milliseconds(throttleIntervalInMilliseconds), scheduler: MainScheduler.instance)// Wait 0.5 for changes.
            .distinctUntilChanged() // If they didn't occur, check if the new value is the same as old.
            .filter { !$0.isEmpty } // If the new value is really new, filter for non-empty query.
            .subscribe(onNext: { [unowned self] query in // Here we subscribe to every new value, that is not empty (thanks to filter above).
                self.searchMovies(searchText: query)
            })
            .disposed(by: bag)
    }
}

extension MovieListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension MovieListViewController: MovieListDisplayLogic {
    func searchMovies(searchText: String) {
        self.viewModel.searchMovie(searchText: searchText)
    }
}

extension MovieListViewController: UISearchBarDelegate {
    
}
