//
//  AppFlowIntegrationTests.swift
//  PocketMovieTests
//
//  Created by 서준일 on 5/18/25.
//

import Testing
import Foundation
import Combine
@testable import PocketMovie

@MainActor
struct AppFlowIntegrationTests {
    
    // MARK: - 전체 사용자 플로우 테스트
    @Test("검색부터 카드 생성까지 전체 플로우")
    func testCompleteUserFlow() async throws {
        // Given - DI 컨테이너 설정
        let container = DIContainer.shared
        let mockAPIService = MockMovieAPIService()
        let mockRepository = MockMovieRepository()
        
        container.container.register(MovieAPIService.self) { _ in mockAPIService }
        container.container.register(MovieRepository.self) { _ in mockRepository }
        container.container.register(MovieUseCase.self) { resolver in
            DefaultMovieUseCase(repository: mockRepository)
        }
        
        // 1. 검색 화면에서 영화 검색
        let searchViewModel = SearchViewModel()
        
        // Mock 검색 결과 설정
        let searchResults = [
            TMDBMovie(
                id: 123,
                title: "인터스텔라",
                originalTitle: "Interstellar",
                posterPath: "/test.jpg",
                backdropPath: "/backdrop.jpg",
                releaseDate: "2014-11-06",
                overview: "우주 탐험 영화",
                voteAverage: 8.6,
                voteCount: 10000
            )
        ]
        mockAPIService.searchMoviesResult = .success(TMDBMovieResponse(
            page: 1,
            results: searchResults,
            totalPages: 1,
            totalResults: 1
        ))
        
        searchViewModel.searchKeyword = "인터스텔라"
        searchViewModel.searchMovies()
        
        // 비동기 작업 완료 대기
        try await Task.sleep(nanoseconds: 200_000_000)
        
        #expect(searchViewModel.searchResults.count == 1)
        #expect(searchViewModel.searchResults.first?.title == "인터스텔라")
        
        // 2. 검색 결과에서 영화 선택하여 카드 생성
        let selectedMovie = searchViewModel.searchResults.first!
        let cardViewModel = CardCreationViewModel(
            movie: selectedMovie,
            movieUseCase: DefaultMovieUseCase(repository: mockRepository)
        )
        
        cardViewModel.saveCard(rating: 5.0, review: "최고의 우주 영화!", genres: ["SF"])
        
        #expect(cardViewModel.showSavedAlert == true)
        
        // 3. 홈 화면에서 저장된 카드 확인
        let homeViewModel = HomeViewModel(
            movieUseCase: DefaultMovieUseCase(repository: mockRepository)
        )
        
        homeViewModel.fetchMovies()
        
        #expect(homeViewModel.movies.count == 1)
        #expect(homeViewModel.movies.first?.title == "인터스텔라")
        #expect(homeViewModel.movies.first?.rating == 5.0)
        #expect(homeViewModel.movies.first?.review == "최고의 우주 영화!")
    }
    
    @Test("박스오피스에서 영화 선택 후 카드 생성")
    func testBoxOfficeToCardCreation() async throws {
        // Given
        let mockAPIService = MockMovieAPIService()
        let mockRepository = MockMovieRepository()
        
        // 박스오피스 Mock 데이터
        let dailyBoxOffice = DailyBoxOfficeResponse(
            boxOfficeResult: DailyBoxOfficeResult(
                boxofficeType: "일별 박스오피스",
                showRange: "20250101~20250101",
                dailyBoxOfficeList: [
                    DailyBoxOffice(rank: "1", movieNm: "파묘", openDt: "2024-02-22")
                ]
            )
        )
        
        mockAPIService.dailyBoxOfficeResult = .success(dailyBoxOffice)
        mockAPIService.weeklyBoxOfficeResult = .success(WeeklyBoxOfficeResponse(
            boxOfficeResult: WeeklyBoxOfficeResult(
                boxofficeType: "주간/주말 박스오피스",
                showRange: "20250101~20250107",
                yearWeekTime: "202501",
                weeklyBoxOfficeList: []
            )
        ))
        
        // TMDB 검색 결과 Mock
        mockAPIService.searchMoviesResult = .success(TMDBMovieResponse(
            page: 1,
            results: [
                TMDBMovie(
                    id: 456,
                    title: "파묘",
                    originalTitle: "Exhuma",
                    posterPath: "/pamyo.jpg",
                    backdropPath: nil,
                    releaseDate: "2024-02-22",
                    overview: "한국 오컬트 영화",
                    voteAverage: 7.8,
                    voteCount: 5000
                )
            ],
            totalPages: 1,
            totalResults: 1
        ))
        
        let container = DIContainer.shared
        container.container.register(MovieAPIService.self) { _ in mockAPIService }
        
        // When
        let searchViewModel = SearchViewModel()
        searchViewModel.loadBoxOfficeData()
        
        // 비동기 작업 완료 대기
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Then
        #expect(!searchViewModel.dailyBoxOfficeMovies.isEmpty)
        #expect(searchViewModel.dailyBoxOfficeMovies.first?.title == "파묘")
        
        // 박스오피스 영화로 카드 생성
        let boxOfficeMovie = searchViewModel.dailyBoxOfficeMovies.first!
        let cardViewModel = CardCreationViewModel(
            movie: boxOfficeMovie,
            movieUseCase: DefaultMovieUseCase(repository: mockRepository)
        )
        
        cardViewModel.saveCard(rating: 4.0, review: "무서웠지만 재밌었다", genres: ["스릴러"])
        
        #expect(cardViewModel.showSavedAlert == true)
    }
    
    @Test("영화 카드 생성 -> 조회 -> 삭제 전체 플로우")
    func testCreateViewDeleteFlow() async throws {
        // Given
        let mockRepository = MockMovieRepository()
        let movieUseCase = DefaultMovieUseCase(repository: mockRepository)
        let homeViewModel = HomeViewModel(movieUseCase: movieUseCase)
        
        // 1. 영화 카드 생성
        let testMovies = [
            MovieTestFactory.createMockMovie(title: "영화1", rating: 5.0),
            MovieTestFactory.createMockMovie(title: "영화2", rating: 4.0),
            MovieTestFactory.createMockMovie(title: "영화3", rating: 3.0)
        ]
        
        for movie in testMovies {
            try movieUseCase.saveMovie(movie)
        }
        
        // 2. 홈 화면에서 조회
        homeViewModel.fetchMovies()
        #expect(homeViewModel.movies.count == 3)
        
        // 3. 선택하여 삭제
        let moviesToDelete = Array(homeViewModel.movies[0...1]) // 첫 2개 선택
        homeViewModel.deleteMovies(moviesToDelete)
        
        // 4. 삭제 후 확인
        #expect(homeViewModel.movies.count == 1)
        #expect(homeViewModel.movies.first?.title == "영화3")
    }
    
    @Test("설정에서 전체 데이터 초기화 플로우")
    func testSettingsDataResetFlow() async throws {
        // Given
        let mockRepository = MockMovieRepository()
        let movieUseCase = DefaultMovieUseCase(repository: mockRepository)
        let dataResetUseCase = DefaultDataResetUseCase(repository: mockRepository)
        
        // 초기 데이터 설정
        for i in 1...5 {
            let movie = MovieTestFactory.createMockMovie(title: "영화\(i)")
            try movieUseCase.saveMovie(movie)
        }
        
        let homeViewModel = HomeViewModel(movieUseCase: movieUseCase)
        homeViewModel.fetchMovies()
        #expect(homeViewModel.movies.count == 5)
        
        // When - 설정에서 데이터 초기화
        let settingsViewModel = SettingsViewModel(dataResetUseCase: dataResetUseCase)
        settingsViewModel.resetAllData()
        
        // Then - 홈 화면 다시 확인
        homeViewModel.fetchMovies()
        #expect(homeViewModel.movies.count == 0)
        #expect(homeViewModel.movies.isEmpty)
    }
    
    // MARK: - 에러 시나리오 통합 테스트
    @Test("네트워크 에러 발생 시 전체 플로우")
    func testNetworkErrorFlow() async throws {
        // Given
        let mockAPIService = MockMovieAPIService()
        mockAPIService.searchMoviesResult = .failure(MockError.networkError)
        
        let container = DIContainer.shared
        container.container.register(MovieAPIService.self) { _ in mockAPIService }
        
        // When
        let searchViewModel = SearchViewModel()
        searchViewModel.searchKeyword = "네트워크 에러 테스트"
        searchViewModel.searchMovies()
        
        // 비동기 작업 완료 대기
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        #expect(searchViewModel.error != nil)
        #expect(searchViewModel.searchResults.isEmpty)
        #expect(searchViewModel.isLoading == false)
    }
}
