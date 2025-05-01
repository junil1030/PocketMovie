//
//  DailyBoxOffice.swift
//  PocketMovie
//
//  Created by 서준일 on 5/1/25.
//

import Foundation

struct DailyBoxOfficeResponse: Codable {
    let boxOfficeResult: DailyBoxOfficeResult
}

struct DailyBoxOfficeResult: Codable {
    let boxofficeType: String
    let showRange: String
    let dailyBoxOfficeList: [DailyBoxOffice]
}

struct DailyBoxOffice: Codable, Identifiable {
    let rank: String
    let movieCd: String
    let movieNm: String
    let openDt: String
    
    var id: String { movieCd }
}
