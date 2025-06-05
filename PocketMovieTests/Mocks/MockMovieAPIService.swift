//
//  MockMovieAPIService.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

import Foundation
import Combine
@testable import PocketMovie

class MockMovieAPIService: MovieAPIService {
    // 호출 횟수 카운팅
    var searchMoviesCallCount = 0
    var fetchDailyBoxOfficeCallCount = 0
    var fetchWeekBoxOfficeCallCount = 0
    var getMovieDetailCallCount = 0
    var getMovieImageCallCount = 0
    
    // Mock 결과
    var searchMoviesResult: Result<TMDBMovieResponse, Error> = .failure(MockError.unknownError)
    var dailyBoxOfficeResult: Result<DailyBoxOfficeResponse, Error> = .failure(MockError.unknownError)
    var weeklyBoxOfficeResult: Result<WeeklyBoxOfficeResponse, Error> = .failure(MockError.unknownError)
    var movieDetailResult: Result<TMDBMovieDetail, Error> = .failure(MockError.unknownError)
    var movieImagesResult: Result<TMDBMovieImagesResponse, Error> = .failure(MockError.unknownError)
    
    func fetchDailyBoxOffice(date: String) -> AnyPublisher<DailyBoxOfficeResponse, Error> {
        fetchDailyBoxOfficeCallCount += 1
        
        return Future<DailyBoxOfficeResponse, Error> { promise in
            switch self.dailyBoxOfficeResult {
            case .success(let response):
                promise(.success(response))
            case .failure(let error):
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchWeeklyBoxOffice(date: String, weekGb: String) -> AnyPublisher<WeeklyBoxOfficeResponse, any Error> {
        fetchWeekBoxOfficeCallCount += 1
        
        return Future<WeeklyBoxOfficeResponse, Error> { promise in
            switch self.weeklyBoxOfficeResult {
            case .success(let response):
                promise(.success(response))
            case .failure(let error):
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func searchMovies(keyword: String) -> AnyPublisher<TMDBMovieResponse, Error> {
        searchMoviesCallCount += 1
        
        return Future<TMDBMovieResponse, Error> { promise in
            switch self.searchMoviesResult {
            case .success(let response):
                promise(.success(response))
            case .failure(let error):
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getMovieDetail(movieId: Int) -> AnyPublisher<TMDBMovieDetail, Error> {
        getMovieDetailCallCount += 1
        
        return Future<TMDBMovieDetail, Error> { promise in
            switch self.movieDetailResult {
            case .success(let response):
                promise(.success(response))
            case .failure(let error):
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getMovieImages(movieId: Int) -> AnyPublisher<TMDBMovieImagesResponse, any Error> {
        getMovieImageCallCount += 1
        
        return Future<TMDBMovieImagesResponse, Error> { promise in
            switch self.movieImagesResult {
            case .success(let response):
                promise(.success(response))
            case .failure(let error):
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
