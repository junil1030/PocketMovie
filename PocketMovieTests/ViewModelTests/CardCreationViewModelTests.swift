//
//  CardCreationViewModelTests.swift
//  PocketMovieTests
//
//  Created by 서준일 on 5/12/25.
//

import Testing
import Foundation
@testable import PocketMovie

@MainActor
@Suite("CardCreationViewModel Tests")
struct CardCreationViewModelTests {
    
    // MARK: - 테스트용 헬퍼
    private func createViewModel(
        movie: TMDBMovie,
        movieUseCase: MovieUseCase
    ) -> CardCreationViewModel {
        return CardCreationViewModel(movie: movie, movieUseCase: movieUseCase)
    }
    
    private func createTestMovie() -> TMDBMovie {
        return TMDBMovie(
            id: 1,
            title: "테스트 영화",
            originalTitle: "Test Movie",
            posterPath: "/test.jpg",
            backdropPath: nil,
            releaseDate: "2025-01-01",
            overview: "테스트 영화입니다",
            voteAverage: 7.5,
            voteCount: 100
        )
    }
    
    // MARK: - 카드 저장 테스트
    
    @Test("카드 저장이 정상적으로 동작하는지")
    func testSaveCardSuccess() async throws {
        // Given
        let mockUseCase = MockMovieUseCase()
        let testMovie = CardCreationViewModelTests().createTestMovie()
        let viewModel = CardCreationViewModelTests().createViewModel(
            movie: testMovie,
            movieUseCase: mockUseCase
        )
        
        // When
        viewModel.saveCard(rating: 4.5, review: "좋은 영화였습니다")
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.showSavedAlert == true)
        #expect(viewModel.errorMessage.isEmpty)
        #expect(mockUseCase.getAllMovies().count == 1)
        
        let savedMovie = mockUseCase.getAllMovies().first
        #expect(savedMovie?.title == "테스트 영화")
        #expect(savedMovie?.rating == 4.5)
        #expect(savedMovie?.review == "좋은 영화였습니다")
    }
    
    @Test("카드 저장 실패 시 에러 처리")
    func testSaveCardFailure() async throws {
        // Given
        let mockUseCase = MockMovieUseCase()
        mockUseCase.setShouldThrowError(true, error: MockError.saveError)
        let testMovie = CardCreationViewModelTests().createTestMovie()
        let viewModel = CardCreationViewModelTests().createViewModel(
            movie: testMovie,
            movieUseCase: mockUseCase
        )
        
        // When
        viewModel.saveCard(rating: 4.0, review: "테스트 리뷰")
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.showErrorAlert == true)
        #expect(!viewModel.errorMessage.isEmpty)
        #expect(viewModel.errorMessage.contains("저장 실패"))
        #expect(mockUseCase.getAllMovies().isEmpty)
    }
    
    @Test("다양한 평점으로 카드 저장")
    func testSaveCardWithVariousRatings() async throws {
        // Given
        let mockUseCase = MockMovieUseCase()
        let testMovie = CardCreationViewModelTests().createTestMovie()
        let viewModel = CardCreationViewModelTests().createViewModel(
            movie: testMovie,
            movieUseCase: mockUseCase
        )
        
        let ratings = [1.0, 2.5, 3.0, 4.5, 5.0]
        
        // When & Then
        for rating in ratings {
            viewModel.saveCard(rating: rating, review: "평점 \(rating) 테스트")
            
            let savedMovies = mockUseCase.getAllMovies()
            let lastMovie = savedMovies.last
            #expect(lastMovie?.rating == rating)
        }
        
        #expect(mockUseCase.getAllMovies().count == ratings.count)
    }
    
    @Test("긴 리뷰로 카드 저장")
    func testSaveCardWithLongReview() async throws {
        // Given
        let mockUseCase = MockMovieUseCase()
        let testMovie = CardCreationViewModelTests().createTestMovie()
        let viewModel = CardCreationViewModelTests().createViewModel(
            movie: testMovie,
            movieUseCase: mockUseCase
        )
        
        let longReview = "정말 감동적인 영화였습니다. 스토리도 좋고 연출도 훌륭했습니다. 배우들의 연기도 인상적이었고 음악도 아름다웠습니다."
        
        // When
        viewModel.saveCard(rating: 5.0, review: longReview)
        
        // Then
        #expect(viewModel.showSavedAlert == true)
        let savedMovie = mockUseCase.getAllMovies().first
        #expect(savedMovie?.review == longReview)
    }
    
    @Test("날짜 정보가 올바르게 저장되는지")
    func testSaveCardWithCorrectDate() async throws {
        // Given
        let mockUseCase = MockMovieUseCase()
        let testMovie = CardCreationViewModelTests().createTestMovie()
        let viewModel = CardCreationViewModelTests().createViewModel(
            movie: testMovie,
            movieUseCase: mockUseCase
        )
        
        let beforeSave = Date()
        
        // When
        viewModel.saveCard(rating: 4.0, review: "날짜 테스트")
        
        let afterSave = Date()
        
        // Then
        let savedMovie = mockUseCase.getAllMovies().first
        #expect(savedMovie != nil)
        if let watchedDate = savedMovie?.watchedDate {
            #expect(watchedDate >= beforeSave && watchedDate <= afterSave)
        }
    }
    
    @Test("포스터 URL이 올바르게 저장되는지")
    func testSaveCardWithPosterURL() async throws {
        // Given
        let mockUseCase = MockMovieUseCase()
        let testMovie = TMDBMovie(
            id: 123,
            title: "포스터 테스트",
            originalTitle: "Poster Test",
            posterPath: "/test-poster.jpg",
            backdropPath: nil,
            releaseDate: "2025-01-01",
            overview: "테스트",
            voteAverage: 7.0,
            voteCount: 100
        )
        
        let viewModel = CardCreationViewModelTests().createViewModel(
            movie: testMovie,
            movieUseCase: mockUseCase
        )
        
        // When
        viewModel.saveCard(rating: 4.0, review: "포스터 URL 테스트")
        
        // Then
        let savedMovie = mockUseCase.getAllMovies().first
        #expect(savedMovie?.posterURL == testMovie.fullPosterURL)
        #expect(savedMovie?.posterURL?.contains("/test-poster.jpg") == true)
    }
    
    // MARK: - 유효성 검증 테스트
    
    @Test("빈 리뷰로 저장 시도")
    func testSaveWithEmptyReview() async throws {
        // Given
        let mockUseCase = MockMovieUseCase()
        let testMovie = CardCreationViewModelTests().createTestMovie()
        let viewModel = CardCreationViewModelTests().createViewModel(
            movie: testMovie,
            movieUseCase: mockUseCase
        )
        
        // When
        viewModel.saveCard(rating: 3.0, review: "")
        
        // Then - 빈 리뷰도 저장 가능 (UI에서 막아야 함)
        #expect(viewModel.showSavedAlert == true)
        let savedMovie = mockUseCase.getAllMovies().first
        #expect(savedMovie?.review == "")
    }
    
    @Test("0점 평점으로 저장 시도")
    func testSaveWithZeroRating() async throws {
        // Given
        let mockUseCase = MockMovieUseCase()
        let testMovie = CardCreationViewModelTests().createTestMovie()
        let viewModel = CardCreationViewModelTests().createViewModel(
            movie: testMovie,
            movieUseCase: mockUseCase
        )
        
        // When
        viewModel.saveCard(rating: 0.0, review: "0점 테스트")
        
        // Then - 0점도 저장 가능 (UI에서 막아야 함)
        #expect(viewModel.showSavedAlert == true)
        let savedMovie = mockUseCase.getAllMovies().first
        #expect(savedMovie?.rating == 0.0)
    }
    
    // MARK: - 상태 관리 테스트
    
    @Test("저장 중 로딩 상태 관리")
    func testLoadingStateDuringSave() async throws {
        // Given
        let mockUseCase = MockMovieUseCase()
        let testMovie = CardCreationViewModelTests().createTestMovie()
        let viewModel = CardCreationViewModelTests().createViewModel(
            movie: testMovie,
            movieUseCase: mockUseCase
        )
        
        // When
        viewModel.saveCard(rating: 4.0, review: "로딩 테스트")
        
        // Then
        #expect(viewModel.isLoading == false) // 동기 작업이므로 즉시 false
    }
    
    @Test("연속 저장 시도")
    func testConsecutiveSaves() async throws {
        // Given
        let mockUseCase = MockMovieUseCase()
        let testMovie = CardCreationViewModelTests().createTestMovie()
        let viewModel = CardCreationViewModelTests().createViewModel(
            movie: testMovie,
            movieUseCase: mockUseCase
        )
        
        // When - 같은 영화를 여러 번 저장
        viewModel.saveCard(rating: 3.0, review: "첫 번째 저장")
        viewModel.saveCard(rating: 4.0, review: "두 번째 저장")
        viewModel.saveCard(rating: 5.0, review: "세 번째 저장")
        
        // Then
        #expect(mockUseCase.getAllMovies().count == 3)
        #expect(viewModel.showSavedAlert == true)
    }
}
