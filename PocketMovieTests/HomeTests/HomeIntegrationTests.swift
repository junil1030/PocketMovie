//
//  HomeIntegrationTests.swift
//  PocketMovie
//
//  Created by 서준일 on 5/10/25.
//

import Testing
import Foundation
import SwiftData
@testable import PocketMovie

@MainActor
struct HomeIntegrationTests {
    
    // MARK: - 테스트용 헬퍼
    private func createInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([Movie.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
    
    private func createRealRepository() throws -> SwiftDataMovieRepository {
        return try SwiftDataMovieRepository()
    }
    
    // MARK: - Repository와 UseCase 통합 테스트
    @Test("실제 Repository와 UseCase를 사용한 영화 저장 및 조회 테스트")
    func testRealRepositoryIntegration() async throws {
        // Given
        let repository = try createRealRepository()
        let useCase = DefaultMovieUseCase(repository: repository)
        let viewModel = HomeViewModel(movieUseCase: useCase)
        
        // When
        let testMovie = MovieTestFactory.createMockMovie(title: "통합 테스트 영화")
        try useCase.saveMovie(testMovie)
        viewModel.fetchMovies()
        
        // Then
        #expect(viewModel.movies.count >= 1)
        #expect(viewModel.movies.contains { $0.title == "통합 테스트 영화" })
        
        // Clean up
        try useCase.deleteMovie(testMovie)
    }
    
    // MARK: - 데이터 일관성 테스트
    @Test("영화 추가 후 즉시 조회했을 때 데이터가 일관성 있게 반영되는지 확인")
    func testDataConsistency() async throws {
        // Given
        let repository = try createRealRepository()
        let useCase = DefaultMovieUseCase(repository: repository)
        let viewModel = HomeViewModel(movieUseCase: useCase)
        
        try repository.deleteAllMovies()
        viewModel.fetchMovies()
        
        let initialCount = viewModel.movies.count
        let newMovie = MovieTestFactory.createMockMovie(title: "일관성 테스트 영화")
        
        // When
        try useCase.saveMovie(newMovie)
        viewModel.fetchMovies()
        
        // Then
        #expect(viewModel.movies.count == initialCount + 1)
        #expect(viewModel.movies.last?.title == "일관성 테스트 영화")
        
        // Clean up
        try useCase.deleteMovie(newMovie)
    }
    
    // MARK: - 에러 처리 통합 테스트
    @Test("실제 시나리오에서 에러 발생 시 ViewModel이 적절히 처리하는지 확인")
    func testErrorHandlingIntegration() async throws {
        let repository = try createRealRepository()
        let useCase = DefaultMovieUseCase(repository: repository)
        let viewModel = HomeViewModel(movieUseCase: useCase)
        
        // 존재하지 않는 영화를 삭제하려고 시도
        let nonExistentMovie = MovieTestFactory.createMockMovie(title: "존재하지 않는 영화")
        
        viewModel.deleteMovie(nonExistentMovie)
        
        #expect(viewModel.isLoading == false)
    }
    
    // MARK: - 성능 테스트
    @Test("대량의 영화 데이터 처리 성능 테스트")
    func testPerformanceWithLargeDataset() async throws {
        let repository = try createRealRepository()
        let useCase = DefaultMovieUseCase(repository: repository)
        let viewModel = HomeViewModel(movieUseCase: useCase)
        
        var testMovies: [Movie] = []
        for i in 1...100 {
            let movie = MovieTestFactory.createMockMovie(
                title: "성능 테스트 영화 \(i)"
            )
            testMovies.append(movie)
        }
        
        let startTime = Date()
        
        for movie in testMovies {
            try useCase.saveMovie(movie)
        }
        viewModel.fetchMovies()
        
        let endTime = Date()
        let processingTime = endTime.timeIntervalSince(startTime)
        
        #expect(viewModel.movies.count >= 100)
        #expect(processingTime < 5.0)
        print("100개 영화 처리 시간: \(processingTime)초")
        
        try useCase.deleteMovies(testMovies)
    }
}
