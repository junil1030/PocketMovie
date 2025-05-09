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
                self?.isLoadingBoxOffice = false
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
                self?.isLoadingBoxOffice = false
            }
            .store(in: &cancellables)
    }
}
