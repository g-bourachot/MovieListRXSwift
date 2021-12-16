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
    
    // MARK: - IButlets
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var plotLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var ratedLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var runTimeLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var directorsLabel: UILabel!
    @IBOutlet weak var writersLabel: UILabel!
    @IBOutlet weak var actorsLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
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
    
    // MARK: - Private functions
    private func setUpSearchMovie() {
        self.viewModel
            .item
            .subscribe(onNext: { [unowned self] movie in
                self.configureView(with: movie)
        })
        .disposed(by: bag)
    }
    
    private func configureView(with movie: Movie) {
        self.title = movie.title
        self.posterImageView.image = nil
        if let posterURL = movie.posterURL {
            self.posterImageView.downloadedFrom(url: posterURL,
                                                contentMode: .scaleAspectFit)
        }
        self.titleLabel.text = movie.title
        self.plotLabel.text = movie.plot
        if let year = movie.year {
            self.yearLabel.text = String(year)
        } else {
            self.yearLabel.text = nil
        }
        
        self.ratedLabel.text = movie.rated
        
        if let releaseDate = movie.releaseDate {
            self.releaseDateLabel.text = Movie.dateFormatter.string(from: releaseDate)
        } else {
            self.releaseDateLabel.text = nil
        }
        
        self.runTimeLabel.text = movie.runTime
        self.genresLabel.text = movie.genres.joined(separator: ", ")
        self.directorsLabel.text = movie.directors.joined(separator: ", ")
        self.writersLabel.text = movie.writers.joined(separator: ", ")
        self.actorsLabel.text = movie.actors.joined(separator: ", ")
        
        if let votes = movie.votes {
            self.votesLabel.text = Movie.numberFormatter.string(from: NSNumber(value: votes))
        } else {
            self.votesLabel.text = nil
        }
        
        if let rating = movie.rating {
            self.ratingLabel.text = String(rating)
        } else {
            self.ratingLabel.text = nil
        }
    }
}
