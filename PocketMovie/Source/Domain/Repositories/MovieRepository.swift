//
//  MovieRepository.swift
//  PocketMovie
//
//  Created by 서준일 on 5/3/25.
//

import Foundation
import SwiftData

@MainActor
protocol MovieRepository {
    func getAllMovies() -> [Movie]
    func getMovie(byId id: PersistentIdentifier) -> Movie?
    func saveMovie(_ movie: Movie) throws
    func updateMovie(_ movie: Movie) throws
    func deleteMovie(_ movie: Movie) throws
    func deleteMovies(_ movies: [Movie]) throws
    func deleteAllMovies() throws
    func getModelContext() -> ModelContext
}
