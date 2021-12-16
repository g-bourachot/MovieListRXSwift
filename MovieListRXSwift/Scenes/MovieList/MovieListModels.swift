//
//  MovieListModels.swift
//  MovieListRXSwift
//
//  Created by Guillaume Bourachot on 16/12/2021.
//

import Foundation

enum MovieList {
    enum CellModel {
        case movie(Movie)
        case error(String)
        case empty
    }
}
