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
    
    var rank: Int?
    var boxOfficeType: String?
    var isBoxOffice: Bool
    
    init(
        title: String,
        releaseDate: String,
        posterURL: String? = nil,
        rating: Double = 0,
        review: String = "",
        watchedDate: Date = Date(),
        rank: Int? = nil,
        boxOfficeType: String? = nil,
        isBoxOffice: Bool = false
    ) {
        self.title = title
        self.releaseDate = releaseDate
        self.posterURL = posterURL
        self.rating = rating
        self.review = review
        self.watchedDate = watchedDate
        self.rank = rank
        self.boxOfficeType = boxOfficeType
        self.isBoxOffice = isBoxOffice
    }
    
    func formattedReleaseDate() -> String {
        return releaseDate.isEmpty ? "정보 없음" : releaseDate
    }
    
    func cleanMovieTitle() -> String {
        var cleanTitle = title
        
        cleanTitle = cleanTitle.replacingOccurrences(of: "!HS", with: "")
        cleanTitle = cleanTitle.replacingOccurrences(of: "!HE", with: "")
        cleanTitle = cleanTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        while cleanTitle.contains("  ") {
            cleanTitle = cleanTitle.replacingOccurrences(of: "  ", with: " ")
        }
        
        return cleanTitle
    }
}
