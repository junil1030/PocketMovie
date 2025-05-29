//
//  TMDBAPIEndpoint.swift
//  PocketMovie
//
//  Created by 서준일 on 5/29/25.
//

import Foundation
import Alamofire

struct TMDBAPIKeys {
    static let apiKey = APIConfig.tmdbAPIKey
}

enum TMDBAPIEndpoint {
    case searchMovies(keyword: String, page: Int = 1)
    case movieDetail(movieId: Int)
}

extension TMDBAPIEndpoint: APIEndpoint {
    var baseURL: String {
        return "https://api.themoviedb.org/3"
    }
    
    var path: String {
        switch self {
        case .searchMovies:
            return "/search/movie"
        case .movieDetail(let movieId):
            return "/movie/\(movieId)"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        var params: Parameters = [
            "api_key": TMDBAPIKeys.apiKey,
            "language": "ko-KR"
        ]
        
        switch self {
        case .searchMovies(let keyword, let page):
            params["query"] = keyword
            params["page"] = page
        case .movieDetail:
            params["append_to_response"] = "credits, videos, similar, recommendations"
        }
        
        return params
    }
}
