//
//  KOBISMovieSearchResponse.swift
//  PocketMovie
//
//  Created by 서준일 on 5/1/25.
//

import Foundation

struct KOBISMovieResponse: Codable {
    let movieListResult: MovieListResult
}

struct MovieListResult: Codable {
    let totCnt: Int
    let source: String
    let movieList: [KOBISMovie]
}

struct KOBISMovie: Codable, Identifiable {
    let movieCd: String
    let movieNm: String
    let prdtYear: String
    let openDt: String
    
    var id: String { movieCd }
}
