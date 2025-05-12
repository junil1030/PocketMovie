//
//  MovieUseCase.swift
//  PocketMovie
//
//  Created by 서준일 on 5/7/25.
//

import Foundation
import SwiftData

@MainActor
protocol MovieUseCase {
    func getAllMovies() -> [Movie]
    func saveMovie(_ movie: Movie) throws
    func updateMovie(_ movie: Movie) throws
    func deleteMovie(_ movie: Movie) throws
    func deleteMovies(_ movies: [Movie]) throws
    func getModelContext() -> ModelContext
}

@MainActor
final class DefaultMovieUseCase: MovieUseCase {
    private let repository: MovieRepository
    
    init(repository: MovieRepository) {
        self.repository = repository
    }
    
    func getAllMovies() -> [Movie] {
        return repository.getAllMovies()
    }
    
    func saveMovie(_ movie: Movie) throws {
        try repository.saveMovie(movie)
    }
    
    func updateMovie(_ movie: Movie) throws {
        try repository.updateMovie(movie)
    }
    
    func deleteMovie(_ movie: Movie) throws {
        try repository.deleteMovie(movie)
    }
    
    func deleteMovies(_ movies: [Movie]) throws {
        try repository.deleteMovies(movies)
    }
    
    func getModelContext() -> ModelContext {
        return repository.getModelContext()
    }
}
