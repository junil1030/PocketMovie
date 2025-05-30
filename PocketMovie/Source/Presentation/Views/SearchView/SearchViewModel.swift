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
    @Published var searchResults: [TMDBMovie] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    // 박스오피스
    @Published var dailyBoxOfficeMovies: [TMDBMovie] = []
    @Published var weeklyBoxOfficeMovies: [TMDBMovie] = []
    @Published var isLoadingBoxOffice = false
    @Published var boxOfficeError: Error?
    
    // 박스오피스 원본 데이터 (순서 유지용)
    private var dailyBoxOfficeList: [DailyBoxOffice] = []
    private var weeklyBoxOfficeList: [WeeklyBoxOffice] = []
    
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
                self?.searchResults = response.results
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
        
        // CombineLatest로 두 API를 동시에 호출
        Publishers.CombineLatest(
            movieAPIService.fetchDailyBoxOffice(date: dailyDate),
            movieAPIService.fetchWeeklyBoxOffice(date: weekDate, weekGb: "0")
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoadingBoxOffice = false
            
            if case .failure(let error) = completion {
                self?.boxOfficeError = error
            }
        } receiveValue: { [weak self] (dailyResponse, weeklyResponse) in
            self?.dailyBoxOfficeList = dailyResponse.boxOfficeResult.dailyBoxOfficeList
            self?.weeklyBoxOfficeList = weeklyResponse.boxOfficeResult.weeklyBoxOfficeList
            self?.processBoxOfficeData()
        }
        .store(in: &cancellables)
    }
    
    // 박스오피스 데이터를 처리하여 TMDB 영화 배열로 변환
    private func processBoxOfficeData() {
        // 중복 제거를 위한 Set (API 호출 최적화용)
        var uniqueMovieTitles = Set<String>()
        
        // 일간 박스오피스 영화들 (10개)
        for movie in dailyBoxOfficeList.prefix(10) {
            uniqueMovieTitles.insert(movie.movieNm)
        }
        
        // 주간 박스오피스 영화들 (10개)
        for movie in weeklyBoxOfficeList.prefix(10) {
            uniqueMovieTitles.insert(movie.movieNm)
        }
        
        // 중복 제거된 영화 제목들로 TMDB 검색
        loadMoviePosters(for: Array(uniqueMovieTitles))
    }
    
    // 여러 영화의 포스터 정보를 TMDB에서 검색
    private func loadMoviePosters(for movieTitles: [String]) {
        let group = DispatchGroup()
        var foundMoviesDict: [String: TMDBMovie] = [:]
        
        for title in movieTitles {
            group.enter()
            
            movieAPIService.searchMovies(keyword: title)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    group.leave()
                } receiveValue: { response in
                    if let foundMovie = self.findBestMatch(
                        searchResults: response.results,
                        targetTitle: title
                    ) {
                        foundMoviesDict[title] = foundMovie
                    }
                }
                .store(in: &cancellables)
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.createOrderedMovieLists(from: foundMoviesDict)
        }
    }
    
    // 원본 박스오피스 순서를 유지하면서 TMDB 영화 배열 생성
    private func createOrderedMovieLists(from moviesDict: [String: TMDBMovie]) {
        // 일간 박스오피스 순서 유지 (1-10위)
        var dailyMovies: [TMDBMovie] = []
        for movie in dailyBoxOfficeList.prefix(10) {
            if let tmdbMovie = moviesDict[movie.movieNm] {
                dailyMovies.append(tmdbMovie)
            }
        }
        
        // 주간 박스오피스 순서 유지 (1-10위)
        var weeklyMovies: [TMDBMovie] = []
        for movie in weeklyBoxOfficeList.prefix(10) {
            if let tmdbMovie = moviesDict[movie.movieNm] {
                weeklyMovies.append(tmdbMovie)
            }
        }
        
        self.dailyBoxOfficeMovies = dailyMovies
        self.weeklyBoxOfficeMovies = weeklyMovies
    }
    
    // TMDB 검색 결과에서 가장 적합한 영화 찾기
    private func findBestMatch(
        searchResults: [TMDBMovie],
        targetTitle: String
    ) -> TMDBMovie? {
        guard !searchResults.isEmpty else { return nil }
        
        // 1. 제목이 정확히 일치하는 영화 찾기
        if let exactMatch = searchResults.first(where: {
            $0.title.lowercased() == targetTitle.lowercased() ||
            $0.originalTitle.lowercased() == targetTitle.lowercased()
        }) {
            return exactMatch
        }
        
        // 2. 제목에 키워드가 포함된 영화 찾기
        if let containsMatch = searchResults.first(where: {
            $0.title.lowercased().contains(targetTitle.lowercased()) ||
            targetTitle.lowercased().contains($0.title.lowercased())
        }) {
            return containsMatch
        }
        
        // 3. 첫 번째 결과 반환
        return searchResults.first
    }
}
