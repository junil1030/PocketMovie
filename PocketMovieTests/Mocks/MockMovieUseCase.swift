//
//  MockMovieUseCase.swift
//  PocketMovie
//
//  Created by 서준일 on 5/10/25.
//

import Foundation
import SwiftData
@testable import PocketMovie

@MainActor
final class MockMovieUseCase: MovieUseCase {
    private var movies: [Movie] = []
    private var shouldThrowError: Bool = false
    private var errorToThrow: Error = MockError.unknown
    
    enum MockError: Error, LocalizedError {
        case saveError
        case deleteError
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .saveError:
                return "저장 실패"
            case .deleteError:
                return "삭제 실패"
            case .unknown:
                return "알 수 없는 오류"
            }
        }
    }
    
    func setMovies(_ movies: [Movie]) {
        self.movies = movies
    }
    
    func setShouldThrowError(_ shouldThrow: Bool, error: Error = MockError.unknown) {
        self.shouldThrowError = shouldThrow
        self.errorToThrow = error
    }
    
    // MARK: - MovieUseCase 구현
    func getAllMovies() -> [Movie] {
        return movies
    }
    
    func saveMovie(_ movie: Movie) throws {
        if shouldThrowError {
            throw errorToThrow
        }
        movies.append(movie)
    }
    
    func updateMovie(_ movie: Movie) throws {
        if shouldThrowError {
            throw errorToThrow
        }
    }
    
    func deleteMovie(_ movie: Movie) throws {
        if shouldThrowError {
            throw MockError.deleteError
        }
        if let index = movies.firstIndex(where: { $0.id == movie.id }) {
            movies.remove(at: index)
        }
    }
    
    func deleteMovies(_ movies: [Movie]) throws {
        if shouldThrowError {
            throw MockError.deleteError
        }
        for movie in movies {
            try deleteMovie(movie)
        }
    }
    
    func getModelContext() -> ModelContext {
        fatalError("ModelContext 제공 x")
    }
}
