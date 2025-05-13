//
//  Movie.swift
//  PocketMovie
//
//  Created by 서준일 on 5/1/25.
//

import Foundation
import SwiftData

@Model
final class Movie {
    var title: String
    var releaseDate: String
    var posterURL: String?
    
    var rating: Double
    var review: String
    var watchedDate: Date
    
    init(
        title: String,
        movieCode: String,
        releaseDate: String,
        posterURL: String? = nil,
        rating: Double,
        review: String,
        watchedDate: Date
    ) {
        self.title = title
        self.releaseDate = releaseDate
        self.posterURL = posterURL
        self.rating = rating
        self.review = review
        self.watchedDate = watchedDate
    }
}
