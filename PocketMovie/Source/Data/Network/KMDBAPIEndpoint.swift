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
    case searchMovies(keyword: String)
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
            "listCount": "50",
            "ServiceKey": KMDBAPIKeys.apiKey
        ]
        
        switch self {
        case .searchMovies(let keyword):
            params["title"] = keyword
        }
        return params
    }
}
