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
    let movieNm: String
    let openDt: String
    
    var id: String { rank }
    
    enum CodingKeys: String, CodingKey {
        case rank, movieNm, openDt
    }

    init(rank: String, movieNm: String, openDt: String) {
        self.rank = rank
        self.movieNm = movieNm
        self.openDt = openDt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        rank = try container.decode(String.self, forKey: .rank)
        movieNm = try container.decodeIfPresent(String.self, forKey: .movieNm) ?? ""
        openDt = try container.decodeIfPresent(String.self, forKey: .openDt) ?? ""
    }
}
