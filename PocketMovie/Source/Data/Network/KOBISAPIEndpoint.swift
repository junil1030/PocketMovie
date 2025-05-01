//
//  KOBISAPIEndpoint.swift
//  PocketMovie
//
//  Created by 서준일 on 5/1/25.
//

import Foundation
import Alamofire

struct KOBISAPIKeys {
    static let apiKey = APIConfig.kobisAPIKey
}

enum KOBISAPIEndpoint {
    case dailyBoxOffice(targetData: String)
    case weeklyBoxOffice(targetDate: String, weekGb: String)
    case searchMovies(keyword: String)
}

extension KOBISAPIEndpoint: APIEndpoint {
    var baseURL: String {
        return "https://www.kobis.or.kr/kobisopenapi/webservice/rest"
    }
    
    var path: String {
        switch self {
        case .dailyBoxOffice:
            return "/boxoffice/searchDailyBoxOfficeList.json"
        case .weeklyBoxOffice:
            return "/boxoffice/searchWeeklyBoxOfficeList.json"
        case .searchMovies:
            return "/movie/searchMovieList.json"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        var params: Parameters = ["key": KOBISAPIKeys.apiKey]
        
        switch self {
        case .dailyBoxOffice(let targetDate):
            params["targetDt"] = targetDate
            
        case .weeklyBoxOffice(let targetDate, let weekGb):
            params["targetDt"] = targetDate
            params["weekGb"] = weekGb
            
        case .searchMovies(let keyword):
            params["movieNm"] = keyword
        }
        
        return params
    }
}
