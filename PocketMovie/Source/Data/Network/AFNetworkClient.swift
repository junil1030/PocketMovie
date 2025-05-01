//
//  NetworkClient.swift
//  PocketMovie
//
//  Created by 서준일 on 5/1/25.
//

import Foundation
import Alamofire
import Combine

protocol NetworkClient {
    func request<T: Decodable>(_ endpoint: APIEndpoint) -> AnyPublisher<T, Error>
}

enum APIError: Error {
    case noData
    case network(AFError)
    case decoding(Error)
}

final class AFNetworkClient: NetworkClient {
    private let session: Session
    
    init(session: Session = .default) {
        self.session = session
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) -> AnyPublisher<T, Error> {
        return session.request(
            endpoint.url,
            method: endpoint.method,
            parameters: endpoint.parameters,
            encoding: endpoint.encoding,
            headers: endpoint.headers
        )
        .validate()
        .publishData()
        .tryMap { response -> Data in
            guard let data = response.data else {
                throw APIError.noData
            }
            return data
        }
        .decode(type: T.self, decoder: JSONDecoder())
        .mapError { error in
            if let afError = error as? AFError {
                return APIError.network(afError)
            } else if error is DecodingError {
                return APIError.decoding(error)
            } else {
                return error
            }
        }
        .eraseToAnyPublisher()
    }
}
