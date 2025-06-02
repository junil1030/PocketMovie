//
//  CardDisplayData.swift
//  PocketMovie
//
//  Created by 서준일 on 6/2/25.
//

import Foundation

struct CardDisplayData {
    let title: String
    let releaseDate: String
    let posterURL: String?
    let rating: Double
    let review: String
    
    init(from movie: Movie) {
        self.title = movie.title
        self.releaseDate = movie.releaseDate
        self.posterURL = movie.posterURL
        self.rating = movie.rating
        self.review = movie.review
    }
    
    init(from movie: TMDBMovie, rating: Double, review: String) {
        self.title = movie.title
        self.releaseDate = movie.releaseDate
        self.posterURL = movie.fullPosterURL
        self.rating = rating
        self.review = review
    }
}
