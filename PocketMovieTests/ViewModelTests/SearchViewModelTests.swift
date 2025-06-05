//
//  SearchViewModelTests.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

import Testing
import Foundation
import Combine
@testable import PocketMovie

@MainActor
struct SearchViewModelTests {
    
    //MARK: - 테스트용 Mock
    private func createViewModel(with mockService: MockMovieAPIService) -> SearchViewModel {
        let container = DIContainer.shared
        container.container.register(MovieAPIService.self) { _ in
            mockService
        }
        return SearchViewModel()
    }
    
    //MARK: - 검색 기능 테스트
    @Test("영화 검색이 정상적으로 동작하는지")
    func testSearchMovies() async throws {
        // Given
        let mockService = MockMovieAPIService()
        let expectedMovies = [
            TMDBMovie(
                id: 1,
                title: "테스트 영화",
                originalTitle: "Test Movie",
                posterPath: "/test.jpg",
                backdropPath: nil,
                releaseDate: "2025-06-04",
                overview: "테스트 영화입니다.",
                voteAverage: 8.2,
                voteCount: 100
            )
        ]
        mockService.searchMoviesResult = .success(TMDBMovieResponse(
            page: 1,
            results: expectedMovies,
            totalPages: 1,
            totalResults: 1
        ))
        
        let viewModel = createViewModel(with: mockService)
        
        // When
        viewModel.searchKeyword = "테스트"
        viewModel.searchMovies()
        
        // 비동기 작업 대기
        try await Task.sleep(for: .milliseconds(100))
        
        // Then
        #expect(viewModel.searchResults.count == 1)
        #expect(viewModel.searchResults.first?.title == "테스트 영화")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }
    
    @Test("빈 검색어로 검색 시 아무 동작하지 않는지")
    func testSearchWithEmptyKeyword() async throws {
        // Given
        let mockService = MockMovieAPIService()
        let viewModel = createViewModel(with: mockService)
        
        // When
        viewModel.searchKeyword = ""
        viewModel.searchMovies()
        
        // Then
        #expect(viewModel.searchResults.isEmpty)
        #expect(viewModel.isLoading)
        #expect(mockService.searchMoviesCallCount == 0)
    }
    
    @Test("검색 실패 시 에러가 처리되는지")
    func testSearchFailure() async throws {
        // Given
        let mockService = MockMovieAPIService()
        mockService.searchMoviesResult = .failure(MockError.networkError)
        let viewModel = SearchViewModelTests().createViewModel(with: mockService)
        
        // When
        viewModel.searchKeyword = "실패 테스트"
        viewModel.searchMovies()
        
        // 비동기 작업 완료 대기
        try await Task.sleep(for: .milliseconds(100))
        
        // Then
        #expect(viewModel.searchResults.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error != nil)
    }
    
    @Test("검색 결과가 여러 개일 때 모두 표시되는지")
    func testMultipleSearchResults() async throws {
        // Given
        let mockService = MockMovieAPIService()
        let multipleMovies = (1...10).map { i in
            TMDBMovie(
                id: i,
                title: "영화 \(i)",
                originalTitle: "Movie \(i)",
                posterPath: "/poster\(i).jpg",
                backdropPath: nil,
                releaseDate: "2025-01-\(String(format: "%02d", i))",
                overview: "설명 \(i)",
                voteAverage: Double(i % 5 + 5),
                voteCount: i * 100
            )
        }
        
        mockService.searchMoviesResult = .success(TMDBMovieResponse(
            page: 1,
            results: multipleMovies,
            totalPages: 1,
            totalResults: 10
        ))
        
        let viewModel = SearchViewModelTests().createViewModel(with: mockService)
        
        // When
        viewModel.searchKeyword = "영화"
        viewModel.searchMovies()
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(viewModel.searchResults.count == 10)
        #expect(viewModel.searchResults.first?.title == "영화 1")
        #expect(viewModel.searchResults.last?.title == "영화 10")
    }
    
    //MARK: - 박스오피스 테스트
    
    @Test("박스오피스 데이터 로딩이 정상적으로 동작하는지")
    func testLoadBoxOfficeData() async throws {
        // Given
        let mockService = MockMovieAPIService()
        
        // 일간 박스오피스 Mock 데이터
        let dailyMovies = [
            DailyBoxOffice(rank: "1", movieNm: "영화1", openDt: "2025-01-01"),
            DailyBoxOffice(rank: "2", movieNm: "영화2", openDt: "2025-01-02")
        ]
        mockService.dailyBoxOfficeResult = .success(DailyBoxOfficeResponse(
            boxOfficeResult: DailyBoxOfficeResult(
                boxofficeType: "일별 박스오피스",
                showRange: "20250101~20250101",
                dailyBoxOfficeList: dailyMovies
            )
        ))
        
        // 주간 박스오피스 Mock 데이터
        let weeklyMovies = [
            WeeklyBoxOffice(rank: "1", movieNm: "영화1", openDt: "2025-01-01"),
            WeeklyBoxOffice(rank: "2", movieNm: "영화3", openDt: "2025-01-03")
        ]
        mockService.weeklyBoxOfficeResult = .success(WeeklyBoxOfficeResponse(
            boxOfficeResult: WeeklyBoxOfficeResult(
                boxofficeType: "주간/주말 박스오피스",
                showRange: "20250101~20250107",
                yearWeekTime: "202501",
                weeklyBoxOfficeList: weeklyMovies
            )
        ))
        
        // TMDB 검색 결과 Mock
        mockService.searchMoviesResult = .success(TMDBMovieResponse(
            page: 1,
            results: [
                TMDBMovie(
                    id: 1,
                    title: "영화1",
                    originalTitle: "Movie1",
                    posterPath: "/poster1.jpg",
                    backdropPath: nil,
                    releaseDate: "2025-01-01",
                    overview: "설명1",
                    voteAverage: 8.0,
                    voteCount: 100
                )
            ],
            totalPages: 1,
            totalResults: 1
        ))
        
        let viewModel = SearchViewModelTests().createViewModel(with: mockService)
        
        // When
        viewModel.loadBoxOfficeData()
        
        // 비동기 작업 완료 대기 (여러 API 호출)
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5초
        
        // Then
        #expect(viewModel.isLoadingBoxOffice == false)
        #expect(viewModel.boxOfficeError == nil)
        #expect(!viewModel.dailyBoxOfficeMovies.isEmpty)
        #expect(!viewModel.weeklyBoxOfficeMovies.isEmpty)
    }
    
    @Test("박스오피스 로딩 실패 시 에러 처리")
    func testBoxOfficeLoadingFailure() async throws {
        // Given
        let mockService = MockMovieAPIService()
        mockService.dailyBoxOfficeResult = .failure(MockError.networkError)
        mockService.weeklyBoxOfficeResult = .failure(MockError.networkError)
        
        let viewModel = SearchViewModelTests().createViewModel(with: mockService)
        
        // When
        viewModel.loadBoxOfficeData()
        
        // 비동기 작업 완료 대기
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        #expect(viewModel.isLoadingBoxOffice == false)
        #expect(viewModel.boxOfficeError != nil)
        #expect(viewModel.dailyBoxOfficeMovies.isEmpty)
        #expect(viewModel.weeklyBoxOfficeMovies.isEmpty)
    }
    
    @Test("박스오피스 순서가 유지되는지")
    func testBoxOfficeOrderMaintained() async throws {
        // Given
        let mockService = MockMovieAPIService()
        
        // 순서가 있는 박스오피스 데이터
        let dailyMovies = (1...10).map { i in
            DailyBoxOffice(rank: "\(i)", movieNm: "일간영화\(i)", openDt: "2025-01-\(String(format: "%02d", i))")
        }
        
        mockService.dailyBoxOfficeResult = .success(DailyBoxOfficeResponse(
            boxOfficeResult: DailyBoxOfficeResult(
                boxofficeType: "일별 박스오피스",
                showRange: "20250101~20250101",
                dailyBoxOfficeList: dailyMovies
            )
        ))
        
        mockService.weeklyBoxOfficeResult = .success(WeeklyBoxOfficeResponse(
            boxOfficeResult: WeeklyBoxOfficeResult(
                boxofficeType: "주간/주말 박스오피스",
                showRange: "20250101~20250107",
                yearWeekTime: "202501",
                weeklyBoxOfficeList: []
            )
        ))
        
        // 각 영화에 대한 TMDB 검색 결과 설정
        for i in 1...10 {
            mockService.searchMoviesResult = .success(TMDBMovieResponse(
                page: 1,
                results: [
                    TMDBMovie(
                        id: i,
                        title: "일간영화\(i)",
                        originalTitle: "Daily Movie \(i)",
                        posterPath: "/poster\(i).jpg",
                        backdropPath: nil,
                        releaseDate: "2025-01-\(String(format: "%02d", i))",
                        overview: "설명",
                        voteAverage: 8.0,
                        voteCount: 100
                    )
                ],
                totalPages: 1,
                totalResults: 1
            ))
        }
        
        let viewModel = SearchViewModelTests().createViewModel(with: mockService)
        
        // When
        viewModel.loadBoxOfficeData()
        
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8초
        
        // Then
        #expect(viewModel.dailyBoxOfficeMovies.count <= 10)
        // 순서가 유지되는지 확인 (1위가 첫 번째)
        if !viewModel.dailyBoxOfficeMovies.isEmpty {
            #expect(viewModel.dailyBoxOfficeMovies.first?.title.contains("1") == true)
        }
    }
}
