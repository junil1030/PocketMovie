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
    private var errorToThrow: Error = MockError.unknownError
    
    func setMovies(_ movies: [Movie]) {
        self.movies = movies
    }
    
    func setShouldThrowError(_ shouldThrow: Bool, error: Error = MockError.unknownError) {
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
        
        movie.rating = normalizeRating(movie.rating)
        movies.append(movie)
    }
    
    func updateMovie(_ movie: Movie) throws {
        if shouldThrowError {
            throw errorToThrow
        }
    }
    
    func deleteMovie(_ movie: Movie) throws {
        if shouldThrowError {
            throw errorToThrow
        }
        if let index = movies.firstIndex(where: { $0.id == movie.id }) {
            movies.remove(at: index)
        }
    }
    
    func deleteMovies(_ movies: [Movie]) throws {
        if shouldThrowError {
            throw errorToThrow
        }
        for movie in movies {
            try deleteMovie(movie)
        }
    }
    
    func getModelContext() -> ModelContext {
        fatalError("ModelContext 제공 x")
    }
    
    private func normalizeRating(_ rating: Double) -> Double {
        if rating.isNaN || rating.isInfinite {
            return 0.0
        }
        return max(0.0, min(5.0, rating))
    }
}
