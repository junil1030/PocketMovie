//
//  SettingsViewModelTests.swift
//  PocketMovieTests
//
//  Created by 서준일 on 5/12/25.
//

import Testing
import Foundation
@testable import PocketMovie

@MainActor
@Suite("SettingsViewModel Tests")
struct SettingsViewModelTests {
    
    // MARK: - 테스트용 헬퍼
    private func createViewModel(with useCase: DataResetUseCase) -> SettingsViewModel {
        return SettingsViewModel(dataResetUseCase: useCase)
    }
    
    // MARK: - 데이터 초기화 테스트
        @Test("데이터 초기화가 정상적으로 동작하는지")
        func testResetAllDataSuccess() async throws {
            // Given
            let mockRepository = MockMovieRepository()
            
            // 초기 데이터 추가
            let testMovies = [
                MovieTestFactory.createMockMovie(title: "영화1"),
                MovieTestFactory.createMockMovie(title: "영화2"),
                MovieTestFactory.createMockMovie(title: "영화3")
            ]
            
            for movie in testMovies {
                try mockRepository.saveMovie(movie)
            }
            
            #expect(mockRepository.getAllMovies().count == 3)
            
            let dataResetUseCase = DefaultDataResetUseCase(repository: mockRepository)
            let viewModel = SettingsViewModelTests().createViewModel(with: dataResetUseCase)
            
            // When
            viewModel.resetAllData()
            
            // Then
            #expect(viewModel.isResetting == false)
            #expect(viewModel.resetError == nil)
            #expect(mockRepository.getAllMovies().isEmpty)
        }
        
        @Test("데이터 초기화 실패 시 에러 처리")
        func testResetAllDataFailure() async throws {
            // Given
            let mockRepository = MockMovieRepository()
            mockRepository.setShouldThrowError(true, error: RepositoryError.deleteError)
            
            let dataResetUseCase = DefaultDataResetUseCase(repository: mockRepository)
            let viewModel = SettingsViewModelTests().createViewModel(with: dataResetUseCase)
            
            // When
            viewModel.resetAllData()
            
            // Then
            #expect(viewModel.isResetting == false)
            #expect(viewModel.resetError != nil)
            if let error = viewModel.resetError as? RepositoryError {
                #expect(error == RepositoryError.deleteError)
            }
        }
        
        @Test("초기화 중 로딩 상태가 올바르게 관리되는지")
        func testLoadingStateManagement() async throws {
            // Given
            let mockRepository = MockMovieRepository()
            let dataResetUseCase = DefaultDataResetUseCase(repository: mockRepository)
            let viewModel = SettingsViewModelTests().createViewModel(with: dataResetUseCase)
            
            // When & Then
            viewModel.resetAllData()
            
            // 초기화 후 로딩 상태가 false여야 함
            #expect(viewModel.isResetting == false)
        }
        
        @Test("빈 데이터에서 초기화 시도")
        func testResetEmptyData() async throws {
            // Given
            let mockRepository = MockMovieRepository()
            let dataResetUseCase = DefaultDataResetUseCase(repository: mockRepository)
            let viewModel = SettingsViewModelTests().createViewModel(with: dataResetUseCase)
            
            // 데이터가 없는 상태 확인
            #expect(mockRepository.getAllMovies().isEmpty)
            
            // When
            viewModel.resetAllData()
            
            // Then
            #expect(viewModel.isResetting == false)
            #expect(viewModel.resetError == nil)
            #expect(mockRepository.getAllMovies().isEmpty)
        }
        
        @Test("대량 데이터 초기화 성능")
        func testLargeDataReset() async throws {
            // Given
            let mockRepository = MockMovieRepository()
            
            // 1000개의 영화 추가
            for i in 1...1000 {
                let movie = MovieTestFactory.createMockMovie(title: "영화\(i)")
                try mockRepository.saveMovie(movie)
            }
            
            #expect(mockRepository.getAllMovies().count == 1000)
            
            let dataResetUseCase = DefaultDataResetUseCase(repository: mockRepository)
            let viewModel = SettingsViewModelTests().createViewModel(with: dataResetUseCase)
            
            // When
            let startTime = Date()
            viewModel.resetAllData()
            let resetTime = Date().timeIntervalSince(startTime)
            
            // Then
            #expect(viewModel.resetError == nil)
            #expect(mockRepository.getAllMovies().isEmpty)
            #expect(resetTime < 1.0) // 1초 이내 완료
            print("1000개 영화 초기화 시간: \(resetTime)초")
        }
    
    // MARK: - 에러 시나리오 테스트
        @Test("다양한 에러 타입 처리")
        func testVariousErrorTypes() async throws {
            // Given
            let errorTypes: [(Error, String)] = [
                (RepositoryError.deleteError, "deleteError"),
                (RepositoryError.contextError, "contextError"),
                (MockError.unknownError, "unknownError")
            ]
            
            for (error, errorName) in errorTypes {
                let mockRepository = MockMovieRepository()
                mockRepository.setShouldThrowError(true, error: error)
                
                let dataResetUseCase = DefaultDataResetUseCase(repository: mockRepository)
                let viewModel = SettingsViewModelTests().createViewModel(with: dataResetUseCase)
                
                // When
                viewModel.resetAllData()
                
                // Then
                #expect(viewModel.resetError != nil, "에러 타입: \(errorName)")
            }
        }
        
        @Test("연속 초기화 시도")
        func testConsecutiveResets() async throws {
            // Given
            let mockRepository = MockMovieRepository()
            let dataResetUseCase = DefaultDataResetUseCase(repository: mockRepository)
            let viewModel = SettingsViewModelTests().createViewModel(with: dataResetUseCase)
            
            // 초기 데이터 추가
            for i in 1...5 {
                let movie = MovieTestFactory.createMockMovie(title: "영화\(i)")
                try mockRepository.saveMovie(movie)
            }
            
            // When - 연속으로 3번 초기화
            viewModel.resetAllData()
            viewModel.resetAllData()
            viewModel.resetAllData()
            
            // Then
            #expect(viewModel.isResetting == false)
            #expect(viewModel.resetError == nil)
            #expect(mockRepository.getAllMovies().isEmpty)
        }
}
