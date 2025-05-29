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
                    self?.loadBoxOfficePosterImages()
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
                    self?.loadBoxOfficePosterImages()
                }
            }
            .store(in: &cancellables)
    }
    
    // KOBIS 박스오피스 영화들의 포스터를 TMDB에서 검색해서 가져오기
    private func loadBoxOfficePosterImages() {
        guard !posterLoadingStarted else { return }
        posterLoadingStarted = true
        
        let movieList = createBoxOfficeMovieList()
        let group = DispatchGroup()
        
        for movie in movieList {
            group.enter()
            
            // TMDB에서 영화 제목으로 검색
            movieAPIService.searchMovies(keyword: movie.title)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    group.leave()
                } receiveValue: { [weak self] response in
                    // 검색 결과에서 가장 적합한 영화 찾기 (개봉년도 비교 등)
                    if let foundMovie = self?.findBestMatch(
                        searchResults: response.results,
                        targetTitle: movie.title,
                        targetReleaseDate: movie.releaseDate
                    ) {
                        self?.posterURLs[movie.title] = foundMovie.fullPosterURL
                    }
                }
                .store(in: &cancellables)
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.posterLoadingComplete = true
        }
    }
    
    // 박스오피스 영화 목록 생성
    private func createBoxOfficeMovieList() -> [(title: String, releaseDate: String)] {
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
    
    // TMDB 검색 결과에서 가장 적합한 영화 찾기
    private func findBestMatch(
        searchResults: [TMDBMovie],
        targetTitle: String,
        targetReleaseDate: String
    ) -> TMDBMovie? {
        guard !searchResults.isEmpty else { return nil }
        
        // 1. 제목이 정확히 일치하는 영화 찾기
        if let exactMatch = searchResults.first(where: {
            $0.title.lowercased() == targetTitle.lowercased() ||
            $0.originalTitle.lowercased() == targetTitle.lowercased()
        }) {
            return exactMatch
        }
        
        // 2. 개봉년도가 비슷한 영화 찾기
        let targetYear = String(targetReleaseDate.prefix(4))
        if let yearMatch = searchResults.first(where: {
            $0.releaseDate.hasPrefix(targetYear)
        }) {
            return yearMatch
        }
        
        // 3. 그냥 첫 번째 결과 반환
        return searchResults.first
    }
    
    func getPosterURLs() -> [String: String] {
        return posterURLs
    }
}
