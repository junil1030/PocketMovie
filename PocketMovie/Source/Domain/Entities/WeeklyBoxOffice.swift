//
//  WeeklyBoxOffice.swift
//  PocketMovie
//
//  Created by 서준일 on 5/1/25.
//

import Foundation

struct WeeklyBoxOfficeResponse: Codable {
    let boxOfficeResult: WeeklyBoxOfficeResult
}

struct WeeklyBoxOfficeResult: Codable {
    let boxofficeType: String
    let showRange: String
    let yearWeekTime: String
    let weeklyBoxOfficeList: [WeeklyBoxOffice]
}

struct WeeklyBoxOffice: Codable, Identifiable {
    let rank: String
    let movieCd: String
    let movieNm: String
    let openDt: String
    
    var id: String { movieCd }
}
