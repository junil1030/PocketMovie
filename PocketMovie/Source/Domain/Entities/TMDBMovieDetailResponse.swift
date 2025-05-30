//
//  TMDBMovieDetailResponse.swift
//  PocketMovie
//
//  Created by 서준일 on 5/30/25.
//

import Foundation

struct TMDBMovieDetail: Codable {
    let id: Int
    let title: String
    let originalTitle: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    let overview: String
    let voteAverage: Double
    let voteCount: Int
    let runtime: Int?
    let genres: [Genre]
    let productionCountries: [ProductionCountry]
    
    let credits: Credits?
    let videos: VideoResponse?
    let similar: SimilarMoviesResponse?
    let recommendations: RecommendationsResponse?
    
    // 포스터 URL 생성
    var fullPosterURL: String? {
        guard let posterPath = posterPath else { return nil }
        return "https://image.tmdb.org/t/p/w500\(posterPath)"
    }
    
    // 백드롭 URL 생성
    var backdropURL: String? {
        guard let backdropPath = backdropPath else { return nil }
        return "https://image.tmdb.org/t/p/w1280\(backdropPath)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime, genres
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case productionCountries = "production_countries"
        case credits, videos, similar, recommendations
    }
}

// 장르 정보
struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
}

// 제작 국가
struct ProductionCountry: Codable {
    let iso31661: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case iso31661 = "iso_3166_1"
        case name
    }
}

// 출연진/제작진 정보
struct Credits: Codable {
    let cast: [CastMember]
    let crew: [CrewMember]
}

struct CastMember: Codable, Identifiable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
    let order: Int
    
    var profileURL: String? {
        guard let profilePath = profilePath else { return nil }
        return "https://image.tmdb.org/t/p/w185\(profilePath)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, character, order
        case profilePath = "profile_path"
    }
}

struct CrewMember: Codable, Identifiable {
    let id: Int
    let name: String
    let job: String
    let department: String
    let profilePath: String?
    
    var profileURL: String? {
        guard let profilePath = profilePath else { return nil }
        return "https://image.tmdb.org/t/p/w185\(profilePath)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, job, department
        case profilePath = "profile_path"
    }
}

// 비디오 정보 (예고편, 클립 등)
struct VideoResponse: Codable {
    let results: [Video]
}

struct Video: Codable, Identifiable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
    let official: Bool
    
    var youtubeURL: String? {
        guard site == "YouTube" else { return nil }
        return "https://www.youtube.com/watch?v=\(key)"
    }
    
    var youtubeThumbnailURL: String? {
        guard site == "YouTube" else { return nil }
        return "https://img.youtube.com/vi/\(key)/maxresdefault.jpg"
    }
}

// 비슷한 영화
struct SimilarMoviesResponse: Codable {
    let results: [TMDBMovie]
}

// 추천 영화
struct RecommendationsResponse: Codable {
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
