//
//  MovieDetailsViewController.swift
//  MovieListRXSwift
//
//  Created by Guillaume Bourachot on 16/12/2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol MovieDetailsDisplayLogic: AnyObject {
    
}

class MovieDetailsViewController: UIViewController {

    // MARK: - Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: "MovieDetailsView", bundle: nil)
    }
    
    // MARK: - Setup
    
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Variables
    var movieIdentifier: Movie.Identifier?
    private let bag = DisposeBag()
    private let viewModel: MovieDetailsViewModelLogic = MovieDetailsViewModel(movieAPI: MovieAPI.shared)
    
    // MARK: - Overrided functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchMovie()
        guard let movieId = self.movieIdentifier else {
            return
        }
        self.viewModel.searchMovieById(movieId)
    }
    
    private func setUpSearchMovie() {
        self.viewModel
            .item
            .subscribe(onNext: { [unowned self] movie in
                self.titleLabel.text = movie.title
        })
        .disposed(by: bag)
    }
}
