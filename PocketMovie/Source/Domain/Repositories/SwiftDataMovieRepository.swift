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
    
    func getAllMovies() -> [Movie] {
        do {
            let descriptor = FetchDescriptor<Movie>(sortBy: [SortDescriptor(\.watchedDate, order: .reverse)])
            return try modelContext.fetch(descriptor)
        } catch {
            print("영화 목록 가져오기 오류: \(error)")
            return []
        }
    }
    
    func getMovie(byId id: PersistentIdentifier) -> Movie? {
        return modelContext.model(for: id) as? Movie
    }
    
    func saveMovie(_ movie: Movie) throws {
        modelContext.insert(movie)
        try modelContext.save()
    }
    
    func updateMovie(_ movie: Movie) throws {
        try modelContext.save()
    }
    
    func deleteMovie(_ movie: Movie) throws {
        modelContext.delete(movie)
        try modelContext.save()
    }
    
    func deleteMovies(_ movies: [Movie]) throws {
        for movie in movies {
            modelContext.delete(movie)
        }
        try modelContext.save()
    }
    
    func deleteAllMovies() throws {
        let descriptor = FetchDescriptor<Movie>()
        do {
            let movies = try modelContext.fetch(descriptor)
            
            for movie in movies {
                modelContext.delete(movie)
            }
            
            try modelContext.save()
        } catch {
            throw RepositoryError.deleteError
        }
    }
    
    func getModelContext() -> ModelContext {
        return modelContext
    }
}
