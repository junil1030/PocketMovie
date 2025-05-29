//
//  TMDBMovieResponse.swift
//  PocketMovie
//
//  Created by 서준일 on 5/29/25.
//

import Foundation

struct TMDBMovieResponse: Codable {
    let page: Int
    let results: [TMDBMovie]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct TMDBMovie: Codable, Identifiable {
    let id: Int
    let title: String
    let originalTitle: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    let overview: String
    let voteAverage: Double
    let voteCount: Int
    
    // 검색 창에 띄울 포스터 URL
    var fullPosterURL: String? {
        guard let posterPath = posterPath else { return nil }
        return "https://image.tmdb.org/t/p/w342\(posterPath)"
    }
    
    // 디테일 창에 띄울 포스터 URL
    var largePosterURL: String? {
        guard let posterPath = posterPath else { return nil }
        return "https://image.tmdb.org/t/p/w500\(posterPath)"
    }
    
    var backdropURL: String? {
        guard let backdropPath = backdropPath else { return nil }
        return "https://image.tmdb.org/t/p/w1280\(backdropPath)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
