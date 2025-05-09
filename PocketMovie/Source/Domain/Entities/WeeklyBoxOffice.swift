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
    let movieNm: String
    let openDt: String
    
    var id: String { rank }
    
    enum CodingKeys: String, CodingKey {
        case rank, movieNm, openDt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.rank = try container.decode(String.self, forKey: .rank)
        self.movieNm = try container.decode(String.self, forKey: .movieNm)
        self.openDt = try container.decode(String.self, forKey: .openDt)
    }
}
