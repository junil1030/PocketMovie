//
//  RepositoryIntegrationTests.swift
//  PocketMovieTests
//
//  Created by 서준일 on 5/15/25.
//

import Testing
import Foundation
import SwiftData
@testable import PocketMovie

@MainActor
struct RepositoryIntegrationTests {
    
    // MARK: - SwiftDataMovieRepository 테스트
    @Test("영화 저장 및 조회가 정상적으로 동작하는지")
    func testSaveAndFetchMovie() async throws {
        // Given
        let repository = try createInMemoryRepository()
        let testMovie = MovieTestFactory.createMockMovie(
            title: "저장 테스트 영화",
            rating: 4.5,
            review: "테스트 리뷰"
        )
        
        // When
        try repository.saveMovie(testMovie)
        let fetchedMovies = repository.getAllMovies()
        
        // Then
        #expect(fetchedMovies.count == 1)
        #expect(fetchedMovies.first?.title == "저장 테스트 영화")
        #expect(fetchedMovies.first?.rating == 4.5)
        #expect(fetchedMovies.first?.review == "테스트 리뷰")
    }
    
    @Test("여러 영화 저장 후 날짜순 정렬 확인")
    func testMultipleMoviesSortedByDate() async throws {
        // Given
        let repository = try createInMemoryRepository()
        
        let movie1 = MovieTestFactory.createMockMovie(
            title: "영화1",
            watchedDate: Date().addingTimeInterval(-86400) // 1일 전
        )
        let movie2 = MovieTestFactory.createMockMovie(
            title: "영화2",
            watchedDate: Date() // 현재
        )
        let movie3 = MovieTestFactory.createMockMovie(
            title: "영화3",
            watchedDate: Date().addingTimeInterval(-172800) // 2일 전
        )
        
        // When
        try repository.saveMovie(movie1)
        try repository.saveMovie(movie2)
        try repository.saveMovie(movie3)
        
        let fetchedMovies = repository.getAllMovies()
        
        // Then
        #expect(fetchedMovies.count == 3)
        #expect(fetchedMovies[0].title == "영화2") // 가장 최신
        #expect(fetchedMovies[1].title == "영화1")
        #expect(fetchedMovies[2].title == "영화3") // 가장 오래됨
    }
    
    @Test("영화 삭제가 정상적으로 동작하는지")
    func testDeleteMovie() async throws {
        // Given
        let repository = try createInMemoryRepository()
        let testMovie = MovieTestFactory.createMockMovie(title: "삭제 테스트 영화")
        
        try repository.saveMovie(testMovie)
        #expect(repository.getAllMovies().count == 1)
        
        // When
        try repository.deleteMovie(testMovie)
        
        // Then
        #expect(repository.getAllMovies().count == 0)
    }
    
    @Test("여러 영화 일괄 삭제")
    func testDeleteMultipleMovies() async throws {
        // Given
        let repository = try createInMemoryRepository()
        let movies = [
            MovieTestFactory.createMockMovie(title: "영화1"),
            MovieTestFactory.createMockMovie(title: "영화2"),
            MovieTestFactory.createMockMovie(title: "영화3")
        ]
        
        for movie in movies {
            try repository.saveMovie(movie)
        }
        #expect(repository.getAllMovies().count == 3)
        
        // When
        try repository.deleteMovies(Array(movies[0...1])) // 첫 2개 삭제
        
        // Then
        let remainingMovies = repository.getAllMovies()
        #expect(remainingMovies.count == 1)
        #expect(remainingMovies.first?.title == "영화3")
    }
    
    @Test("모든 영화 삭제")
    func testDeleteAllMovies() async throws {
        // Given
        let repository = try createInMemoryRepository()
        
        for i in 1...5 {
            let movie = MovieTestFactory.createMockMovie(title: "영화\(i)")
            try repository.saveMovie(movie)
        }
        #expect(repository.getAllMovies().count == 5)
        
        // When
        try repository.deleteAllMovies()
        
        // Then
        #expect(repository.getAllMovies().count == 0)
    }
    
    @Test("영화 업데이트")
    func testUpdateMovie() async throws {
        // Given
        let repository = try createInMemoryRepository()
        let testMovie = MovieTestFactory.createMockMovie(
            title: "원본 제목",
            rating: 3.0,
            review: "원본 리뷰"
        )
        
        try repository.saveMovie(testMovie)
        
        // When
        testMovie.rating = 5.0
        testMovie.review = "수정된 리뷰"
        try repository.updateMovie(testMovie)
        
        // Then
        let updatedMovies = repository.getAllMovies()
        #expect(updatedMovies.count == 1)
        #expect(updatedMovies.first?.rating == 5.0)
        #expect(updatedMovies.first?.review == "수정된 리뷰")
    }
    
    // MARK: - 헬퍼 메서드
    private func createInMemoryRepository() throws -> SwiftDataMovieRepository {
        // 테스트용 인메모리 레포지토리 생성
        // 실제 구현에서는 ModelConfiguration을 인메모리로 설정
        return try SwiftDataMovieRepository()
    }
}
