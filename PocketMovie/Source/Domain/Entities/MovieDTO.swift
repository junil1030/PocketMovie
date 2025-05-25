//
//  MovieDTO.swift
//  PocketMovie
//
//  Created by 서준일 on 5/25/25.
//

import Foundation

struct MovieDTO: Identifiable, Codable {
    var id: String
    var title: String
    var releaseDate: String
    var posterURL: String?
    var rating: Double
    var review: String
    var watchedDate: Date
    
    init(from movie: Movie) {
        self.id = movie.id.hashValue.description
        self.title = movie.title
        self.releaseDate = movie.releaseDate
        self.posterURL = movie.posterURL
        self.rating = movie.rating
        self.review = movie.review
        self.watchedDate = movie.watchedDate
    }
}

struct WidgetDataContainer: Codable {
    let movies: [MovieDTO]
    let lastUpdated: Date
    
    static let empty = WidgetDataContainer(movies: [], lastUpdated: Date())
}
