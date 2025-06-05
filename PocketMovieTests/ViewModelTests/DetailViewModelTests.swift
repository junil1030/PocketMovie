//
//  DetailViewModelTests.swift
//  PocketMovieTests
//
//  Created by 서준일 on 5/12/25.
//

import Testing
import Foundation
import Combine
@testable import PocketMovie

@MainActor
@Suite("DetailViewModel Tests")
struct DetailViewModelTests {
    
    // MARK: - 테스트용 헬퍼
    private func createViewModel(movieId: Int, with mockService: MockMovieAPIService) -> DetailViewModel {
        let container = DIContainer.shared
        container.container.register(MovieAPIService.self) { _ in
            mockService
        }
        return DetailViewModel(movieId: movieId)
    }
    
    private func createMockMovieDetail() -> TMDBMovieDetail {
        return TMDBMovieDetail(
            id: 1,
            title: "테스트 영화",
            originalTitle: "Test Movie",
            posterPath: "/test.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "2025-01-01",
            overview: "테스트 영화 설명입니다.",
            voteAverage: 8.0,
            voteCount: 1000,
            runtime: 120,
            genres: [Genre(id: 28, name: "액션")],
            productionCountries: [ProductionCountry(iso31661: "US", name: "United States")],
            credits: Credits(
                cast: [
                    CastMember(id: 1, name: "배우1", character: "주인공", profilePath: "/actor1.jpg", order: 0)
                ],
                crew: [
                    CrewMember(id: 2, name: "감독1", job: "Director", department: "Directing", profilePath: "/director1.jpg")
                ]
            ),
            videos: VideoResponse(results: [
                Video(id: "1", key: "abc123", name: "예고편", site: "YouTube", type: "Trailer", official: true)
            ]),
            similar: SimilarMoviesResponse(results: []),
            recommendations: RecommendationsResponse(page: 1, results: [], totalPages: 1, totalResults: 0)
        )
    }
    
    private func createMockMovieImages() -> TMDBMovieImagesResponse {
        return TMDBMovieImagesResponse(
            id: 1,
            backdrops: [
                MovieImage(
                    aspectRatio: 1.778,
                    height: 1080,
                    iso6391: "en",
                    filePath: "/backdrop1.jpg",
                    voteAverage: 5.5,
                    voteCount: 10,
                    width: 1920
                )
            ],
            logos: [],
            posters: []
        )
    }
    
    // MARK: - 영화 상세 정보 로딩 테스트
    @Test("영화 상세 정보 로딩이 정상적으로 동작하는지")
    func testLoadMovieDetailSuccess() async throws {
        // Given
        let mockService = MockMovieAPIService()
        let mockDetail = DetailViewModelTests().createMockMovieDetail()
        let mockImages = DetailViewModelTests().createMockMovieImages()
        
        mockService.movieDetailResult = .success(mockDetail)
        mockService.movieImagesResult = .success(mockImages)
        
        let viewModel = DetailViewModelTests().createViewModel(movieId: 1, with: mockService)
        
        // When
        viewModel.loadMovieDetail()
        
        // 비동기 작업 완료 대기
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2초
        
        // Then
        #expect(viewModel.movieDetail != nil)
        #expect(viewModel.movieDetail?.title == "테스트 영화")
        #expect(viewModel.movieImages != nil)
        #expect(viewModel.movieImages?.backdrops.count == 1)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }
    
    @Test("영화 상세 정보 로딩 실패 시 에러 처리")
    func testLoadMovieDetailFailure() async throws {
        // Given
        let mockService = MockMovieAPIService()
        mockService.movieDetailResult = .failure(MockError.networkError)
        mockService.movieImagesResult = .failure(MockError.networkError)
        
        let viewModel = DetailViewModelTests().createViewModel(movieId: 1, with: mockService)
        
        // When
        viewModel.loadMovieDetail()
        
        // 비동기 작업 완료 대기
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        #expect(viewModel.movieDetail == nil)
        #expect(viewModel.movieImages == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error != nil)
    }
    
    @Test("영화 상세 정보는 성공, 이미지는 실패한 경우")
    func testPartialLoadingSuccess() async throws {
        // Given
        let mockService = MockMovieAPIService()
        let mockDetail = DetailViewModelTests().createMockMovieDetail()
        
        mockService.movieDetailResult = .success(mockDetail)
        mockService.movieImagesResult = .failure(MockError.networkError)
        
        let viewModel = DetailViewModelTests().createViewModel(movieId: 1, with: mockService)
        
        // When
        viewModel.loadMovieDetail()
        
        // 비동기 작업 완료 대기
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        #expect(viewModel.movieDetail == nil) // CombineLatest 때문에 둘 다 성공해야 함
        #expect(viewModel.movieImages == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error != nil)
    }
    
    // MARK: - 상세 정보 콘텐츠 테스트
    
    @Test("출연진 정보가 올바르게 로드되는지")
    func testLoadCastInformation() async throws {
        // Given
        let mockService = MockMovieAPIService()
        let mockDetail = DetailViewModelTests().createMockMovieDetail()
        let mockImages = DetailViewModelTests().createMockMovieImages()
        
        mockService.movieDetailResult = .success(mockDetail)
        mockService.movieImagesResult = .success(mockImages)
        
        let viewModel = DetailViewModelTests().createViewModel(movieId: 1, with: mockService)
        
        // When
        viewModel.loadMovieDetail()
        
        // 비동기 작업 완료 대기
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        #expect(viewModel.movieDetail?.credits?.cast.count == 1)
        #expect(viewModel.movieDetail?.credits?.cast.first?.name == "배우1")
        #expect(viewModel.movieDetail?.credits?.crew.count == 1)
        #expect(viewModel.movieDetail?.credits?.crew.first?.job == "Director")
    }
    
    @Test("비디오 정보가 올바르게 로드되는지")
    func testLoadVideoInformation() async throws {
        // Given
        let mockService = MockMovieAPIService()
        let mockDetail = DetailViewModelTests().createMockMovieDetail()
        let mockImages = DetailViewModelTests().createMockMovieImages()
        
        mockService.movieDetailResult = .success(mockDetail)
        mockService.movieImagesResult = .success(mockImages)
        
        let viewModel = DetailViewModelTests().createViewModel(movieId: 1, with: mockService)
        
        // When
        viewModel.loadMovieDetail()
        
        // 비동기 작업 완료 대기
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        let videos = viewModel.movieDetail?.videos?.results ?? []
        #expect(videos.count == 1)
        #expect(videos.first?.site == "YouTube")
        #expect(videos.first?.type == "Trailer")
        #expect(videos.first?.youtubeURL == "https://www.youtube.com/watch?v=abc123")
    }
    
    @Test("장르 및 제작 국가 정보")
    func testGenreAndProductionInfo() async throws {
        // Given
        let mockService = MockMovieAPIService()
        let mockDetail = TMDBMovieDetail(
            id: 1,
            title: "테스트 영화",
            originalTitle: "Test Movie",
            posterPath: "/test.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "2025-01-01",
            overview: "테스트 영화 설명입니다.",
            voteAverage: 8.0,
            voteCount: 1000,
            runtime: 120,
            genres: [
                Genre(id: 28, name: "액션"),
                Genre(id: 12, name: "모험"),
                Genre(id: 878, name: "SF")
            ],
            productionCountries: [
                ProductionCountry(iso31661: "US", name: "United States"),
                ProductionCountry(iso31661: "KR", name: "South Korea")
            ],
            credits: nil,
            videos: nil,
            similar: nil,
            recommendations: nil
        )
        let mockImages = DetailViewModelTests().createMockMovieImages()
        
        mockService.movieDetailResult = .success(mockDetail)
        mockService.movieImagesResult = .success(mockImages)
        
        let viewModel = DetailViewModelTests().createViewModel(movieId: 1, with: mockService)
        
        // When
        viewModel.loadMovieDetail()
        
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        #expect(viewModel.movieDetail?.genres.count == 3)
        #expect(viewModel.movieDetail?.genres.contains { $0.name == "액션" } == true)
        #expect(viewModel.movieDetail?.productionCountries.count == 2)
        #expect(viewModel.movieDetail?.productionCountries.contains { $0.iso31661 == "KR" } == true)
    }
    
    // MARK: - 로딩 상태 관리 테스트
    @Test("로딩 상태가 올바르게 변경되는지")
    func testLoadingStateTransitions() async throws {
        // Given
        let mockService = MockMovieAPIService()
        let mockDetail = DetailViewModelTests().createMockMovieDetail()
        let mockImages = DetailViewModelTests().createMockMovieImages()
        
        mockService.movieDetailResult = .success(mockDetail)
        mockService.movieImagesResult = .success(mockImages)
        
        let viewModel = DetailViewModelTests().createViewModel(movieId: 1, with: mockService)
        
        // Initial state
        #expect(viewModel.isLoading == false)
        
        // When
        viewModel.loadMovieDetail()
        
        // During loading
        #expect(viewModel.isLoading == true)
        
        // After completion
        try await Task.sleep(nanoseconds: 200_000_000)
        #expect(viewModel.isLoading == false)
    }
    
    @Test("여러 번 로딩 시도")
    func testMultipleLoadAttempts() async throws {
        // Given
        let mockService = MockMovieAPIService()
        let mockDetail = DetailViewModelTests().createMockMovieDetail()
        let mockImages = DetailViewModelTests().createMockMovieImages()
        
        mockService.movieDetailResult = .success(mockDetail)
        mockService.movieImagesResult = .success(mockImages)
        
        let viewModel = DetailViewModelTests().createViewModel(movieId: 1, with: mockService)
        
        // When - 3번 연속 로딩
        for _ in 1...3 {
            viewModel.loadMovieDetail()
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        
        // Then
        #expect(viewModel.movieDetail != nil)
        #expect(viewModel.isLoading == false)
        #expect(mockService.getMovieDetailCallCount >= 3)
    }
}
