//
//  SwiftDataMovieRepository.swift
//  PocketMovie
//
//  Created by 서준일 on 5/3/25.
//

import Foundation
import SwiftData

enum RepositoryError: Error {
    case contextError
    case fetchError
    case saveError
    case deleteError
}

@MainActor
final class SwiftDataMovieRepository: MovieRepository {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() throws {
        let schema = Schema([Movie.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        self.modelContext = modelContainer.mainContext
    }
    
    func getAllMovies() async throws -> [Movie] {
        return try await Task {
            let desciptor = FetchDescriptor<Movie>(sortBy: [SortDescriptor(\.watchedDate, order: .reverse)])
            return try modelContext.fetch(desciptor)
        }.value
    }
    
    func getMovie(byId id: PersistentIdentifier) async -> Movie? {
        await Task {
            modelContext.model(for: id) as? Movie
        }.value
    }
    
    func saveMovie(_ movie: Movie) async throws {
        try await Task {
            modelContext.insert(movie)
            try modelContext.save()
        }.value
    }
    
    func updateMovie(_ movie: Movie) async throws {
        try await Task {
            try modelContext.save()
        }.value
    }
    
    func deleteMovie(_ movie: Movie) async throws {
        try await Task {
            modelContext.delete(movie)
            try modelContext.save()
        }.value
    }
    
    func deleteMovies(_ movies: [Movie]) async throws {
        try await Task {
            for movie in movies {
                modelContext.delete(movie)
            }
            try modelContext.save()
        }.value
    }
    
    func deleteAllMovies() async throws {
        try await Task {
            let descriptor = FetchDescriptor<Movie>()
            let movies = try modelContext.fetch(descriptor)
            
            for movie in movies {
                modelContext.delete(movie)
            }
            
            try modelContext.save()
        }.value
    }
    
    func getModelContext() -> ModelContext {
        return modelContext
    }
}
