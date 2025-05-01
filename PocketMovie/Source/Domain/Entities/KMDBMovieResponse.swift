//
//  KMDBMovieResponse.swift
//  PocketMovie
//
//  Created by 서준일 on 5/1/25.
//

import Foundation

struct KMDBMovieResponse: Codable {
    let RESULT: KMDBResult
    let Data: [KMDBData]
}

struct KMDBResult: Codable {
    let TOTAL_COUNT: Int
    let rows: Int
}

struct KMDBData: Codable {
    let Result: [KMDBMovie]
}

struct KMDBMovie: Codable, Identifiable {
    let DOCID: String
    let title: String
    let titleEng: String
    let plot: String
    let posters: String
    let prodYear: String
    let openDate: String
    
    var id: String { DOCID }
    
    // 첫 번째 포스터 URL을 반환
    var firstPosterURL: String? {
        let urls = posters.split(separator: "|").map { String($0) }
        return urls.first
    }
}
