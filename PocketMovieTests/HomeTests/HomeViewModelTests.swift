//
//  HomeViewModelTests.swift
//  PocketMovie
//
//  Created by 서준일 on 5/10/25.
//

import Testing
import Foundation
@testable import PocketMovie

@MainActor
struct HomeViewModelTests {
    
    //MARK: - 테스트용 헬퍼
    private func createViewModel(with movies: [Movie] = []) -> (HomeViewModel, MockMovieUseCase) {
        let mockUseCase = MockMovieUseCase()
        mockUseCase.setMovies(movies)
        let viewModel = HomeViewModel(movieUseCase: mockUseCase)
        return (viewModel, mockUseCase)
    }
    
    //MARK: - 초기화 테스트
    @Test("HomeViewModel 초기화 시 영화 목록이 로드되는지")
    func testInitialization() async throws {
        let mockMovies = MovieTestFactory.createMockMovies()
        
        let (viewModel, _) = createViewModel(with: mockMovies)
        
        #expect(viewModel.movies.count == 3)
        #expect(viewModel.movies[0].title == "인터스텔라")
        #expect(viewModel.movies[1].title == "어벤져스: 엔드게임")
        #expect(viewModel.movies[2].title == "듄")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }
    
    @Test("HomeViewModel 초기화 시 빈 목록이 정상적으로 처리되는지")
    func testInitializationWithEmptyList() async throws {
        let (viewModel, _) = createViewModel()
        
        #expect(viewModel.movies.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }
    
    // MARK: - 영화 조회 테스트
    @Test("fetchMovies 호출 시 영화 목록이 업데이트되는지")
    func testFetchMovies() async throws {
        let (viewModel, mockUseCase) = createViewModel()
        let newMovies = MovieTestFactory.createMockMovies()
        
        mockUseCase.setMovies(newMovies)
        viewModel.fetchMovies()
        
        #expect(viewModel.movies.count == 3)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }
    
    // MARK: - 영화 삭제 테스트
    @Test("단일 영화 삭제가 정상적으로 동작하는지")
    func testDeleteSingleMovie() async throws {
        let mockMovies = MovieTestFactory.createMockMovies()
        let (viewModel, _) = createViewModel(with: mockMovies)
        let movieToDelete = mockMovies[0]
        
        viewModel.deleteMovie(movieToDelete)
        
        #expect(viewModel.movies.count == 2)
        #expect(!viewModel.movies.contains { $0.id == movieToDelete.id })
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }
    
    @Test("단일 영화 삭제 실패 시 에러가 처리되는지")
    func testDeleteSingleMovieFailure() async throws {
        let mockMovies = MovieTestFactory.createMockMovies()
        let (viewModel, mockUseCase) = createViewModel(with: mockMovies)
        let movieToDelete = mockMovies[0]
        
        mockUseCase.setShouldThrowError(true, error: MockMovieUseCase.MockError.deleteError)
        
        viewModel.deleteMovie(movieToDelete)
        
        #expect(viewModel.movies.count == 3)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error != nil)
    }
    
    @Test("여러 영화 삭제가 정상적으로 동작하는지")
    func testDeleteMultipleMovies() async throws {
        let mockMovies = MovieTestFactory.createMockMovies()
        let (viewModel, _) = createViewModel(with: mockMovies)
        let moviesToDelete = Array(mockMovies[0...1]) // 첫 번째, 두 번째 영화 삭제
        
        viewModel.deleteMovies(moviesToDelete)
        
        #expect(viewModel.movies.count == 1)
        #expect(viewModel.movies[0].title == "듄")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }
    
    @Test("여러 영화 삭제 실패 시 에러가 처리되는지")
    func testDeleteMultipleMoviesFailure() async throws {
        let mockMovies = MovieTestFactory.createMockMovies()
        let (viewModel, mockUseCase) = createViewModel(with: mockMovies)
        let moviesToDelete = Array(mockMovies[0...1])
        
        mockUseCase.setShouldThrowError(true, error: MockMovieUseCase.MockError.deleteError)
        
        viewModel.deleteMovies(moviesToDelete)
    
        #expect(viewModel.movies.count == 3)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error != nil)
    }
    
    // MARK: - 로딩 상태 테스트
    @Test("영화 삭제 중 로딩 상태가 올바르게 관리되는지")
    func testLoadingStateManagement() async throws {
        let mockMovies = MovieTestFactory.createMockMovies()
        let (viewModel, _) = createViewModel(with: mockMovies)
        
        viewModel.deleteMovie(mockMovies[0])
        
        #expect(viewModel.isLoading == false)
    }
}
