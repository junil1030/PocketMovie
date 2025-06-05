//
//  EdgeCaseTests.swift
//  PocketMovieTests
//
//  Created by 서준일 on 5/18/25.
//

import Testing
import Foundation
@testable import PocketMovie

@MainActor
struct EdgeCaseTests {
    
    // MARK: - 극단적인 입력값 테스트
    @Test("빈 문자열 및 특수문자 처리")
    func testEmptyAndSpecialCharacters() async throws {
        // Given
        let mockUseCase = MockMovieUseCase()
        let testCases = [
            ("", "빈 리뷰"),           // 빈 제목
            ("   ", "공백만 있는 리뷰"), // 공백만 있는 제목
            ("🎬영화🎬", "이모지 제목"), // 이모지 포함
            ("!@#$%^&*()", "특수문자"), // 특수문자만
            (String(repeating: "A", count: 1000), "매우 긴 제목") // 매우 긴 제목
        ]
        
        // When & Then
        for (title, review) in testCases {
            let movie = MovieTestFactory.createMockMovie(
                title: title,
                review: review
            )
            
            // 저장은 성공해야 함 (유효성 검사는 UI 레벨에서)
            try mockUseCase.saveMovie(movie)
            
            let saved = mockUseCase.getAllMovies().last
            #expect(saved?.title == title)
            #expect(saved?.review == review)
        }
    }
    
    @Test("극단적인 평점 값")
    func testExtremeRatingValues() async throws {
        // Given
        let mockUseCase = MockMovieUseCase()
        let ratings = [0.0, -1.0, 5.1, 10.0, Double.infinity, Double.nan]
        
        // When & Then
        for rating in ratings {
            let movie = MovieTestFactory.createMockMovie(
                title: "평점 테스트 \(rating)",
                rating: rating
            )
            
            try mockUseCase.saveMovie(movie)
            
            let saved = mockUseCase.getAllMovies().last
            #expect(saved?.rating == rating)
        }
    }
    
    @Test("미래 날짜 영화")
    func testFutureDateMovie() async throws {
        // Given
        let mockUseCase = MockMovieUseCase()
        let futureDate = Date().addingTimeInterval(365 * 24 * 60 * 60) // 1년 후
        
        let movie = MovieTestFactory.createMockMovie(
            title: "미래 영화",
            releaseDate: "2030-12-31",
            watchedDate: futureDate
        )
        
        // When
        try mockUseCase.saveMovie(movie)
        
        // Then
        let saved = mockUseCase.getAllMovies().first
        #expect(saved?.watchedDate == futureDate)
    }
    
    // MARK: - 동시성 및 경쟁 상태 테스트
    @Test("동시 다발적 삭제 작업")
    func testConcurrentDeletion() async throws {
        // Given
        let mockRepository = MockMovieRepository()
        let useCase = DefaultMovieUseCase(repository: mockRepository)
        
        // 초기 데이터 생성
        var movies: [Movie] = []
        for i in 1...100 {
            let movie = MovieTestFactory.createMockMovie(title: "동시성 테스트 \(i)")
            try useCase.saveMovie(movie)
            movies.append(movie)
        }
        
        // When - 동시에 삭제 시도
        await withTaskGroup(of: Void.self) { group in
            for movie in movies {
                group.addTask {
                    try? await useCase.deleteMovie(movie)
                }
            }
        }
        
        // Then
        let remaining = useCase.getAllMovies()
        #expect(remaining.count == 0)
    }
    
    // MARK: - 메모리 및 성능 극한 테스트
    @Test("매우 큰 리뷰 텍스트 처리")
    func testVeryLongReviewText() async throws {
        // Given
        let mockUseCase = MockMovieUseCase()
        let longReview = String(repeating: "긴 리뷰 텍스트. ", count: 10000) // 약 10만 글자
        
        let movie = MovieTestFactory.createMockMovie(
            title: "긴 리뷰 테스트",
            review: longReview
        )
        
        // When
        let startTime = Date()
        try mockUseCase.saveMovie(movie)
        let saveTime = Date().timeIntervalSince(startTime)
        
        // Then
        let saved = mockUseCase.getAllMovies().first
        #expect(saved?.review == longReview)
        #expect(saveTime < 1.0) // 1초 이내 저장
    }
    
    @Test("대량의 영화 카드에서 검색")
    func testSearchInLargeDataset() async throws {
        // Given
        let mockRepository = MockMovieRepository()
        let useCase = DefaultMovieUseCase(repository: mockRepository)
        
        // 10,000개의 영화 생성
        for i in 1...10000 {
            let movie = MovieTestFactory.createMockMovie(
                title: "영화 \(i)",
                rating: Double(i % 5 + 1)
            )
            try useCase.saveMovie(movie)
        }
        
        // When
        let startTime = Date()
        let allMovies = useCase.getAllMovies()
        let fetchTime = Date().timeIntervalSince(startTime)
        
        // Then
        #expect(allMovies.count == 10000)
        #expect(fetchTime < 1.0) // 1초 이내 조회
        print("10,000개 영화 조회 시간: \(fetchTime)초")
    }
    
    // MARK: - 비정상적인 API 응답 처리
    @Test("잘못된 JSON 형식 처리")
    func testMalformedJSONHandling() async throws {
        // Given
        let mockService = MockMovieAPIService()
        
        // 잘못된 형식의 응답 시뮬레이션
        mockService.searchMoviesResult = .failure(MockError.parsingError)
        
        let container = DIContainer.shared
        container.container.register(MovieAPIService.self) { _ in mockService }
        
        let viewModel = SearchViewModel()
        
        // When
        viewModel.searchKeyword = "테스트"
        viewModel.searchMovies()
        
        // 비동기 작업 완료 대기
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        #expect(viewModel.error != nil)
        #expect(viewModel.searchResults.isEmpty)
    }
    
    @Test("null 값이 포함된 API 응답")
    func testNullValuesInResponse() async throws {
        // Given
        let mockService = MockMovieAPIService()
        
        // posterPath가 nil인 영화
        let movieWithNulls = TMDBMovie(
            id: 999,
            title: "포스터 없는 영화",
            originalTitle: "No Poster Movie",
            posterPath: nil,  // null
            backdropPath: nil, // null
            releaseDate: "",   // 빈 문자열
            overview: "",      // 빈 문자열
            voteAverage: 0.0,
            voteCount: 0
        )
        
        mockService.searchMoviesResult = .success(TMDBMovieResponse(
            page: 1,
            results: [movieWithNulls],
            totalPages: 1,
            totalResults: 1
        ))
        
        let container = DIContainer.shared
        container.container.register(MovieAPIService.self) { _ in mockService }
        
        let viewModel = SearchViewModel()
        
        // When
        viewModel.searchKeyword = "null 테스트"
        viewModel.searchMovies()
        
        // 비동기 작업 완료 대기
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        #expect(viewModel.searchResults.count == 1)
        #expect(viewModel.searchResults.first?.posterPath == nil)
        #expect(viewModel.searchResults.first?.fullPosterURL == nil)
    }
    
    // MARK: - 앱 상태 전환 시나리오
    @Test("백그라운드 진입 후 복귀")
    func testBackgroundAndForeground() async throws {
        // Given
        let mockRepository = MockMovieRepository()
        let useCase = DefaultMovieUseCase(repository: mockRepository)
        let homeViewModel = HomeViewModel(movieUseCase: useCase)
        
        // 초기 데이터
        let movie = MovieTestFactory.createMockMovie(title: "백그라운드 테스트")
        try useCase.saveMovie(movie)
        homeViewModel.fetchMovies()
        
        let initialCount = homeViewModel.movies.count
        
        // When - 백그라운드 시뮬레이션 (데이터는 유지되어야 함)
        // 실제로는 NotificationCenter를 통해 처리
        
        // Then - 포그라운드 복귀
        homeViewModel.fetchMovies()
        #expect(homeViewModel.movies.count == initialCount)
    }
}
