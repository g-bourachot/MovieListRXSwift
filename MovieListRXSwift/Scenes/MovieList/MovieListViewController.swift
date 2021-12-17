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
import MBProgressHUD

protocol MovieListDisplayLogic: AnyObject {
    func searchMovies(searchText: String)
    func routeToDetail(movieId: Movie.Identifier)
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
    private let throttleIntervalInMilliseconds = 500
    
    // MARK: - Overrided functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rx.setDelegate(self).disposed(by: bag)
        bindTableView()
        self.setupSearchChangeHandling()
        self.viewModel.displayEmptyCell()
        self.viewModel.setDelegate(to: self)
    }
    
    private func bindTableView() {
        self.tableView.register(UINib(nibName: "MovieListTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieListTableViewCell")
        self.tableView.register(UINib(nibName: "ErrorTableViewCell", bundle: nil), forCellReuseIdentifier: "ErrorTableViewCell")
        self.tableView.register(UINib(nibName: "EmptyTableViewCell", bundle: nil), forCellReuseIdentifier: "EmptyTableViewCell")
        viewModel.items.bind(to: tableView
                                .rx
                                .items) { tableView, index, element in
            let indexPath = IndexPath(item: index, section: 0)
            switch element {
            case .movie(let movie):
                guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "MovieListTableViewCell",
                                                                    for: indexPath) as? MovieListTableViewCell else {
                    return UITableViewCell()
                }
                cell.configureCell(with: movie)
                return cell
            case .error(let errorMessage):
                guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "ErrorTableViewCell",
                                                                    for: indexPath) as? ErrorTableViewCell else {
                    return UITableViewCell()
                }
                cell.configureCell(with: errorMessage)
                return cell
            case .empty:
                guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell",
                                                                    for: indexPath) as? EmptyTableViewCell else {
                    return UITableViewCell()
                }
                return cell
            }
        }.disposed(by: bag)
        
        tableView.rx.modelSelected(MovieList.CellModel.self).subscribe(onNext: { cellModel in
            if case .movie(let movie) = cellModel {
                self.routeToDetail(movieId: movie.identifier)
            }
        }).disposed(by: bag)
        
        tableView.tableFooterView = UIView()
    }
    
    private func setupSearchChangeHandling() {
        uiSearchBar
            .rx.text
            .orEmpty
            .observe(on: MainScheduler.asyncInstance)
            .throttle(.milliseconds(throttleIntervalInMilliseconds), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [unowned self] query in
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
    
    func routeToDetail(movieId: Movie.Identifier) {
        let destinationVC = MovieDetailsViewController()
        destinationVC.movieIdentifier = movieId
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
}

extension MovieListViewController: MovieListViewModelDelegate {
    func showLoader(_ should: Bool) {
        if should {
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
        } else {
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    }
}
