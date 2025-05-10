//
//  SearchViewModel.swift
//  PocketMovie
//
//  Created by 서준일 on 5/9/25.
//

import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    private let movieAPIService: MovieAPIService
    private var cancellables = Set<AnyCancellable>()
    
    // 검색 관련
    @Published var searchKeyword = ""
    @Published var searchResults: [KMDBMovie] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    // 박스오피스
    @Published var dailyBoxOfficeList: [DailyBoxOffice] = []
    @Published var weeklyBoxOfficeList: [WeeklyBoxOffice] = []
    @Published var isLoadingBoxOffice = false
    @Published var boxOfficeError: Error?
    
    // 포스터
    private var posterURLs: [String: String] = [:]
    @Published var posterLoadingComplete: Bool = false
    private var posterLoadingStarted: Bool = false
    
    init() {
        let container = DIContainer.shared
        self.movieAPIService = container.container.resolve(MovieAPIService.self)!
        
        loadBoxOfficeData()
    }
    
    func searchMovies() {
        guard !searchKeyword.isEmpty else { return }
        
        isLoading = true
        error = nil
        searchResults.removeAll()
        
        movieAPIService.searchMovies(keyword: searchKeyword)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] response in
                if let movies = response.Data.first?.Result {
                    self?.searchResults = movies
                }
            }
            .store(in: &cancellables)
    }
    
    func loadBoxOfficeData() {
        isLoadingBoxOffice = true
        boxOfficeError = nil
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dailyDate = dateFormatter.string(from: yesterday)
        let weekDate = dateFormatter.string(from: weekAgo)
        
        print("일간 박스오피스 데이터 로드 시작 - 타겟 날짜: \(dailyDate)")
        print("주간 박스오피스 데이터 로드 시작 - 타겟 날짜: \(weekDate)")
        
        // 일간 박스오피스
        loadDailyBoxOfficeData(date: dailyDate)
        
        // 주간 박스오피스
        loadWeeklyBoxOfficeData(date: weekDate)
    }
    
    private func loadDailyBoxOfficeData(date: String) {
        movieAPIService.fetchDailyBoxOffice(date: date)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.boxOfficeError = error
                    self?.isLoadingBoxOffice = false
                }
            } receiveValue: { [weak self] response in
                self?.dailyBoxOfficeList = response.boxOfficeResult.dailyBoxOfficeList
                
                if !(self?.weeklyBoxOfficeList.isEmpty ?? true) {
                    self?.isLoadingBoxOffice = false
                    self?.loadAllPosters()
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadWeeklyBoxOfficeData(date: String) {
        movieAPIService.fetchWeeklyBoxOffice(date: date, weekGb: "0")
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.boxOfficeError = error
                    self?.isLoadingBoxOffice = false
                }
            } receiveValue: { [weak self] response in
                self?.weeklyBoxOfficeList = response.boxOfficeResult.weeklyBoxOfficeList
                
                if !(self?.dailyBoxOfficeList.isEmpty ?? true) {
                    self?.isLoadingBoxOffice = false
                    self?.loadAllPosters()
                }
            }
            .store(in: &cancellables)
    }
    
    private func createMovieList() -> [(title: String, releaseDate: String)] {
        var movieList = [String: String]()
        
        for movie in dailyBoxOfficeList {
            movieList[movie.movieNm] = movie.openDt
        }
        
        for movie in weeklyBoxOfficeList {
            if movieList[movie.movieNm] == nil {
                movieList[movie.movieNm] = movie.openDt
            }
        }
        
        return movieList.map { (title: $0.key, releaseDate: $0.value) }
    }
    
    func loadAllPosters() {
        guard !posterLoadingStarted else { return }
        posterLoadingStarted = true
        
        let movieList = createMovieList()
        let group = DispatchGroup()
        
        for movie in movieList {
            group.enter()
            
            movieAPIService.searchMovieWithReleaseDate(keyword: movie.title, releaseDts: movie.releaseDate)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    group.leave()
                } receiveValue: { [weak self] response in
                    if let foundMovie = response.Data.first?.Result.first {
                        if movie.releaseDate.replacingOccurrences(of: "-", with: "") == foundMovie.repRlsDate {
                            self?.posterURLs[movie.title] = foundMovie.firstPosterURL
                        } else {
                            self?.posterURLs[movie.title] = nil
                        }
                    }
                }
                .store(in: &cancellables)
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.posterLoadingComplete = true
        }
    }
    
    func getPosterURL(for movieTitle: String) -> String? {
        return posterURLs[movieTitle]
    }
}
