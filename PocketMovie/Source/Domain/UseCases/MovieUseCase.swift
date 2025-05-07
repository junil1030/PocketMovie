//
//  MovieUseCase.swift
//  PocketMovie
//
//  Created by 서준일 on 5/7/25.
//

import Foundation
import SwiftData

protocol MovieUseCase {
    func getAllMovies() async throws -> [Movie]
    func saveMovie(_ movie: Movie) async throws
    func updateMovie(_ movie: Movie) async throws
    func deleteMovie(_ movie: Movie) async throws
    func deleteMovies(_ movies: [Movie]) async throws
    func deleteAllMovies() async throws
    
    @MainActor
    func getModelContext() -> ModelContext
}

final class DefaultMovieUseCase: MovieUseCase {
    private let repository: MovieRepository
    
    init(repository: MovieRepository) {
        self.repository = repository
    }
    
    func getAllMovies() async throws -> [Movie] {
        return try await repository.getAllMovies()
    }
    
    func saveMovie(_ movie: Movie) async throws {
        try await repository.saveMovie(movie)
    }
    
    func updateMovie(_ movie: Movie) async throws {
        try await repository.updateMovie(movie)
    }
    
    func deleteMovie(_ movie: Movie) async throws {
        try await repository.deleteMovie(movie)
    }
    
    func deleteMovies(_ movies: [Movie]) async throws {
        try await repository.deleteMovies(movies)
    }
    
    func deleteAllMovies() async throws {
        try await repository.deleteAllMovies()
    }
    
    @MainActor
    func getModelContext() -> ModelContext {
        return repository.getModelContext()
    }
}
