//
//  MovieAPIService.swift
//  PocketMovie
//
//  Created by 서준일 on 5/1/25.
//

import Foundation
import Combine

protocol MovieAPIService {
    func fetchDailyBoxOffice(date: String) -> AnyPublisher<DailyBoxOfficeResponse, Error>
    func fetchWeeklyBoxOffice(date: String, weekGb: String) -> AnyPublisher<WeeklyBoxOfficeResponse, Error>
    
    func searchMovies(keyword: String) -> AnyPublisher<TMDBMovieResponse, Error>
    func getMovieDetail(movieId: Int) -> AnyPublisher<TMDBMovieDetail, Error>
    func getMovieImages(movieId: Int) -> AnyPublisher<TMDBMovieImagesResponse, Error>
}

final class DefaultMovieAPIService: MovieAPIService {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func fetchDailyBoxOffice(date: String) -> AnyPublisher<DailyBoxOfficeResponse, Error> {
        let endpoint = KOBISAPIEndpoint.dailyBoxOffice(targetData: date)
        return networkClient.request(endpoint)
    }
    
    func fetchWeeklyBoxOffice(date: String, weekGb: String = "0") -> AnyPublisher<WeeklyBoxOfficeResponse, Error> {
        let endpoint = KOBISAPIEndpoint.weeklyBoxOffice(targetDate: date, weekGb: weekGb)
        return networkClient.request(endpoint)
    }
    
    func searchMovies(keyword: String) -> AnyPublisher<TMDBMovieResponse, Error> {
        let endpoint = TMDBAPIEndpoint.searchMovies(keyword: keyword)
        return networkClient.request(endpoint)
    }
    
    func getMovieDetail(movieId: Int) -> AnyPublisher<TMDBMovieDetail, Error> {
        let endpoint = TMDBAPIEndpoint.movieDetail(movieId: movieId)
        return networkClient.request(endpoint)
    }
    
    func getMovieImages(movieId: Int) -> AnyPublisher<TMDBMovieImagesResponse, Error> {
        let endpoint = TMDBAPIEndpoint.movieImages(movieId: movieId)
        return networkClient.request(endpoint)
    }
}
