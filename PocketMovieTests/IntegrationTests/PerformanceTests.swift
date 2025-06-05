//
//  PerformanceTests.swift
//  PocketMovieTests
//
//  Created by 서준일 on 5/18/25.
//

import Testing
import Foundation
@testable import PocketMovie

@MainActor
struct PerformanceTests {
    
    // MARK: - 메모리 사용량 테스트
    @Test("대량 이미지 URL 처리 시 메모리 효율성")
    func testMemoryEfficiencyWithImages() async throws {
        // Given
        let mockRepository = MockMovieRepository()
        let useCase = DefaultMovieUseCase(repository: mockRepository)
        
        // 1000개의 영화 (각각 다른 포스터 URL)
        var memoryBefore = getMemoryUsage()
        
        for i in 1...1000 {
            let movie = MovieTestFactory.createMockMovie(
                title: "영화 \(i)",
                posterURL: "https://example.com/poster\(i).jpg"
            )
            try useCase.saveMovie(movie)
        }
        
        let memoryAfter = getMemoryUsage()
        let memoryIncrease = memoryAfter - memoryBefore
        
        // Then
        print("메모리 증가량: \(memoryIncrease / 1024 / 1024)MB")
        #expect(memoryIncrease < 50 * 1024 * 1024) // 50MB 미만
    }
    
    // MARK: - 응답 시간 테스트
    @Test("영화 목록 조회 응답 시간")
    func testFetchMoviesResponseTime() async throws {
        // Given
        let mockRepository = MockMovieRepository()
        let useCase = DefaultMovieUseCase(repository: mockRepository)
        let homeViewModel = HomeViewModel(movieUseCase: useCase)
        
        // 500개의 영화 추가
        for i in 1...500 {
            let movie = MovieTestFactory.createMockMovie(title: "영화 \(i)")
            try useCase.saveMovie(movie)
        }
        
        // When
        let measurements = (0..<10).map { _ -> TimeInterval in
            let start = Date()
            homeViewModel.fetchMovies()
            return Date().timeIntervalSince(start)
        }
        
        let averageTime = measurements.reduce(0, +) / Double(measurements.count)
        let maxTime = measurements.max() ?? 0
        
        // Then
        print("평균 조회 시간: \(averageTime * 1000)ms")
        print("최대 조회 시간: \(maxTime * 1000)ms")
        
        #expect(averageTime < 0.1) // 평균 100ms 미만
        #expect(maxTime < 0.2) // 최대 200ms 미만
    }
    
    @Test("검색 결과 처리 속도")
    func testSearchPerformance() async throws {
        // Given
        let mockService = MockMovieAPIService()
        
        // 100개의 검색 결과
        let largeResults = (1...100).map { i in
            TMDBMovie(
                id: i,
                title: "영화 \(i)",
                originalTitle: "Movie \(i)",
                posterPath: "/poster\(i).jpg",
                backdropPath: nil,
                releaseDate: "2025-01-01",
                overview: "설명 \(i)",
                voteAverage: Double(i % 10),
                voteCount: i * 100
            )
        }
        
        mockService.searchMoviesResult = .success(TMDBMovieResponse(
            page: 1,
            results: largeResults,
            totalPages: 10,
            totalResults: 1000
        ))
        
        let container = DIContainer.shared
        container.container.register(MovieAPIService.self) { _ in mockService }
        
        let viewModel = SearchViewModel()
        
        // When
        let start = Date()
        viewModel.searchKeyword = "테스트"
        viewModel.searchMovies()
        
        // 비동기 작업 완료 대기
        try await Task.sleep(nanoseconds: 300_000_000)
        
        let elapsed = Date().timeIntervalSince(start)
        
        // Then
        print("100개 검색 결과 처리 시간: \(elapsed * 1000)ms")
        #expect(elapsed < 0.5) // 500ms 미만
        #expect(viewModel.searchResults.count == 100)
    }
    
    // MARK: - 스크롤 성능 테스트
    @Test("대량 데이터 스크롤 시뮬레이션")
    func testScrollPerformance() async throws {
        // Given
        let mockRepository = MockMovieRepository()
        let useCase = DefaultMovieUseCase(repository: mockRepository)
        
        // 5000개의 영화 생성
        let movies = (1...5000).map { i in
            MovieTestFactory.createMockMovie(
                title: "스크롤 테스트 \(i)",
                posterURL: "https://example.com/poster\(i).jpg",
                rating: Double(i % 5 + 1)
            )
        }
        
        // 배치로 저장
        let batchSize = 100
        for i in stride(from: 0, to: movies.count, by: batchSize) {
            let batch = Array(movies[i..<min(i + batchSize, movies.count)])
            for movie in batch {
                try useCase.saveMovie(movie)
            }
        }
        
        // When - 페이지네이션 시뮬레이션
        var loadTimes: [TimeInterval] = []
        let pageSize = 20
        
        for page in 0..<10 {
            let start = Date()
            
            // 페이지별 데이터 로드 시뮬레이션
            let allMovies = useCase.getAllMovies()
            let startIndex = page * pageSize
            let endIndex = min(startIndex + pageSize, allMovies.count)
            _ = Array(allMovies[startIndex..<endIndex])
            
            loadTimes.append(Date().timeIntervalSince(start))
        }
        
        let averageLoadTime = loadTimes.reduce(0, +) / Double(loadTimes.count)
        
        // Then
        print("페이지별 평균 로드 시간: \(averageLoadTime * 1000)ms")
        #expect(averageLoadTime < 0.05) // 50ms 미만
    }
    
    // MARK: - 헬퍼 메서드
    private func getMemoryUsage() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        return result == KERN_SUCCESS ? Int64(info.resident_size) : 0
    }
}
