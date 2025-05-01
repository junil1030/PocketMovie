//
//  KMDBAPIEndpoint.swift
//  PocketMovie
//
//  Created by 서준일 on 5/1/25.
//

import Foundation
import Alamofire

struct KMDBAPIKeys {
    static let apiKey = APIConfig.kmdbAPIKey
}

enum KMDBAPIEndpoint {
    case movieDetail(movieCd: String)
    case searchMovies(keyword: String, page: Int)
}

extension KMDBAPIEndpoint: APIEndpoint {
    var baseURL: String {
        return "https://api.koreafilm.or.kr/openapi-data2/wisenut/search_api"
    }
    
    var path: String {
        return "/search_json2.jsp"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        var params: Parameters = [
            "collection": "kmdb_new2",
            "detail": "Y",
            "ServiceKey": KMDBAPIKeys.apiKey
        ]
        
        switch self {
        case .movieDetail(let movieCd):
            params["movieId"] = movieCd
            
        case .searchMovies(let keyword, let page):
            params["query"] = keyword
            params["startCount"] = (page - 1) * 10
            params["listCount"] = 10
        }
        
        return params
    }
}
