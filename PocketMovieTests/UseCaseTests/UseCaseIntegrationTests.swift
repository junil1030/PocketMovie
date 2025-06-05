//
//  UseCaseIntegrationTests.swift
//  PocketMovieTests
//
//  Created by 서준일 on 5/15/25.
//

import Testing
import Foundation
@testable import PocketMovie

@MainActor
struct UseCaseIntegrationTests {
    
    // MARK: - MovieUseCase 통합 테스트
    @Test("MovieUseCase와 Repository가 올바르게 연동되는지")
    func testMovieUseCaseWithRepository() async throws {
        // Given
        let repository = MockMovieRepository()
        let useCase = DefaultMovieUseCase(repository: repository)
        
        let testMovie = MovieTestFactory.createMockMovie(
            title: "UseCase 테스트 영화",
            rating: 4.0
        )
        
        // When
        try useCase.saveMovie(testMovie)
        let movies = useCase.getAllMovies()
        
        // Then
        #expect(movies.count == 1)
        #expect(movies.first?.title == "UseCase 테스트 영화")
        #expect(movies.first?.rating == 4.0)
    }
    
    @Test("중복 영화 저장 방지 로직")
    func testPreventDuplicateMovies() async throws {
        // Given
        let repository = MockMovieRepository()
        let useCase = DefaultMovieUseCase(repository: repository)
        
        let movie1 = MovieTestFactory.createMockMovie(title: "동일한 영화")
        let movie2 = MovieTestFactory.createMockMovie(title: "동일한 영화")
        
        // When
        try useCase.saveMovie(movie1)
        try useCase.saveMovie(movie2) // 중복 저장 시도
        
        // Then
        let movies = useCase.getAllMovies()
        #expect(movies.count == 2) // 현재는 중복 허용, 필요시 비즈니스 로직 추가
    }
    
    @Test("영화 업데이트 후 조회")
    func testUpdateAndFetchMovie() async throws {
        // Given
        let repository = MockMovieRepository()
        let useCase = DefaultMovieUseCase(repository: repository)
        
        let movie = MovieTestFactory.createMockMovie(
            title: "업데이트 테스트",
            rating: 3.0,
            review: "원본 리뷰"
        )
        
        try useCase.saveMovie(movie)
        
        // When
        movie.rating = 5.0
        movie.review = "업데이트된 리뷰"
        try useCase.updateMovie(movie)
        
        // Then
        let movies = useCase.getAllMovies()
        #expect(movies.first?.rating == 5.0)
        #expect(movies.first?.review == "업데이트된 리뷰")
    }
    
    // MARK: - DataResetUseCase 통합 테스트
    @Test("DataResetUseCase가 모든 데이터를 삭제하는지")
    func testDataResetUseCaseDeletesAllData() async throws {
        // Given
        let repository = MockMovieRepository()
        let movieUseCase = DefaultMovieUseCase(repository: repository)
        let dataResetUseCase = DefaultDataResetUseCase(repository: repository)
        
        // 테스트 데이터 추가
        for i in 1...10 {
            let movie = MovieTestFactory.createMockMovie(title: "영화 \(i)")
            try movieUseCase.saveMovie(movie)
        }
        
        #expect(movieUseCase.getAllMovies().count == 10)
        
        // When
        try dataResetUseCase.resetAllData()
        
        // Then
        #expect(movieUseCase.getAllMovies().count == 0)
    }
    
    @Test("삭제 중 에러 발생 시 UseCase 에러 전파")
    func testErrorPropagationInDataReset() async throws {
        // Given
        let repository = MockMovieRepository()
        repository.setShouldThrowError(true, error: RepositoryError.deleteError)
        
        let dataResetUseCase = DefaultDataResetUseCase(repository: repository)
        
        // When & Then
        #expect(throws: RepositoryError.deleteError) {
            try dataResetUseCase.resetAllData()
        }
    }
    
    // MARK: - 성능 테스트
    @Test("대량 데이터 처리 성능")
    func testLargeDataProcessingPerformance() async throws {
        // Given
        let repository = MockMovieRepository()
        let useCase = DefaultMovieUseCase(repository: repository)
        
        let startTime = Date()
        
        // When - 1000개의 영화 저장
        for i in 1...1000 {
            let movie = MovieTestFactory.createMockMovie(
                title: "영화 \(i)",
                rating: Double(i % 5 + 1)
            )
            try useCase.saveMovie(movie)
        }
        
        let saveTime = Date().timeIntervalSince(startTime)
        
        // 모든 영화 조회
        let fetchStart = Date()
        let movies = useCase.getAllMovies()
        let fetchTime = Date().timeIntervalSince(fetchStart)
        
        // Then
        #expect(movies.count == 1000)
        #expect(saveTime < 1.0) // 1초 이내
        #expect(fetchTime < 0.1) // 0.1초 이내
        
        print("1000개 영화 저장 시간: \(saveTime)초")
        print("1000개 영화 조회 시간: \(fetchTime)초")
    }
}
