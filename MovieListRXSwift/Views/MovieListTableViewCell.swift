//
//  MovieListTableViewCell.swift
//  MovieListRXSwift
//
//  Created by Guillaume Bourachot on 15/12/2021.
//

import Foundation
import UIKit
import GBExtensions

class MovieListTableViewCell: UITableViewCell {
 
    // MARK: - IBOutlets
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!

    // MARK: - Public functions
    func configureCell(with movie: Movie) {
        self.posterImageView.image = nil
        self.movieTitleLabel.text = movie.title
        if let posterURL = movie.posterURL {
            self.posterImageView.downloadedFrom(url: posterURL,
                                                contentMode: .scaleAspectFit)
        }
    }
}