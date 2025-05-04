//
//  MovieRepository.swift
//  PocketMovie
//
//  Created by 서준일 on 5/3/25.
//

import Foundation
import SwiftData

protocol MovieRepository {
    func getAllMovies() async throws -> [Movie]
    func getMovie(byId id: PersistentIdentifier) async -> Movie?
    func saveMovie(_ movie: Movie) async throws
    func updateMovie(_ movie: Movie) async throws
    func deleteMovie(_ movie: Movie) async throws
    func deleteMovies(_ movie: [Movie]) async throws
    func deleteAllMovies() async throws
    
    @MainActor
    func getModelContext() -> ModelContext
}
