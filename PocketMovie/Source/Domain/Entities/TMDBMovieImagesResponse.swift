//
//  TMDBMovieImagesResponse.swift
//  PocketMovie
//
//  Created by 서준일 on 5/30/25.
//

import Foundation

struct TMDBMovieImagesResponse: Codable {
    let id: Int
    let backdrops: [MovieImage]
    let logos: [MovieImage]
    let posters: [MovieImage]
}

struct MovieImage: Codable, Identifiable {
    let aspectRatio: Double
    let height: Int
    let iso6391: String?
    let filePath: String
    let voteAverage: Double
    let voteCount: Int
    let width: Int
    
    var id: String { filePath }
    
    // 이미지 URL 생성
    var fullImageURL: String {
        "https://image.tmdb.org/t/p/w500\(filePath)"
    }
    
    var originalImageURL: String {
        "https://image.tmdb.org/t/p/original\(filePath)"
    }
    
    enum CodingKeys: String, CodingKey {
        case aspectRatio = "aspect_ratio"
        case height
        case iso6391 = "iso_639_1"
        case filePath = "file_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case width
    }
}
