//
//  APIEndpoint.swift
//  PocketMovie
//
//  Created by 서준일 on 5/1/25.
//

import Foundation
import Alamofire

protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: HTTPHeaders? { get }
    var encoding: ParameterEncoding { get }
}

extension APIEndpoint {
    var url: URL {
        return URL(string: baseURL + path)!
    }
    
    var encoding: ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
