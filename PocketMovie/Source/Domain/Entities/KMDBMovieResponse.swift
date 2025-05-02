//
//  KMDBMovieResponse.swift
//  PocketMovie
//
//  Created by 서준일 on 5/1/25.
//

import Foundation

struct KMDBMovieResponse: Codable {
    let TotalCount: Int
    let Data: [KMDBData]
}

struct KMDBData: Codable {
    let Result: [KMDBMovie]
}

struct KMDBMovie: Codable, Identifiable {
    let DOCID: String
    let title: String
    let posters: String
    let repRlsDate: String
    
    var id: String { DOCID }
    
    // 첫 번째 포스터 URL을 반환
    var firstPosterURL: String? {
        let urls = posters.split(separator: "|").map { String($0) }
        if let url = urls.first?.trimmingCharacters(in: .whitespacesAndNewlines) {
            // HTTP를 HTTPS로 변환
            if url.hasPrefix("http://") {
                return url.replacingOccurrences(of: "http://", with: "https://")
            }
            return url
        }
        return nil
    }
    
    var cleanTitle: String {
        var cleanTitle = title
        
        cleanTitle = cleanTitle.replacingOccurrences(of: "!HS", with: "")
        cleanTitle = cleanTitle.replacingOccurrences(of: "!HE", with: "")
        
        cleanTitle = cleanTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        while cleanTitle.contains("  ") {
            cleanTitle = cleanTitle.replacingOccurrences(of: "  ", with: " ")
        }
        
        return cleanTitle
    }
    
    enum CodingKeys: String, CodingKey {
        case DOCID, title, posters, repRlsDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        DOCID = try container.decode(String.self, forKey: .DOCID)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        posters = try container.decodeIfPresent(String.self, forKey: .posters) ?? ""
        repRlsDate = try container.decodeIfPresent(String.self, forKey: .repRlsDate) ?? ""
    }
}
