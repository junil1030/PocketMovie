//
//  MockMovieRepository.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

import Foundation
import SwiftData
@testable import PocketMovie

@MainActor
final class MockMovieRepository: MovieRepository {
    private var movies: [Movie] = []
    private var shouldThrowError: Bool = false
    private var errorToThrow: Error = MockError.fetchError
    
    // 테스트용 메서드
    func setMovies(_ movies: [Movie]) {
        self.movies = movies
    }
    
    func setShouldThrowError(_ shouldThrow: Bool, error: Error = MockError.fetchError) {
        self.shouldThrowError = shouldThrow
        self.errorToThrow = error
    }
    
    //MARK: - MovieRepository 구현
    func getAllMovies() -> [Movie] {
        return movies
    }
    
    func getMovie(byId id: PersistentIdentifier) -> Movie? {
        // 첫 번째 영화 하나만 반환하는 걸로
        return movies.first
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
        // 업데이트는 생략하도록 함
    }
    
    func deleteMovie(_ movie: Movie) throws {
        if shouldThrowError {
            throw errorToThrow
        }
        movies.removeAll { $0.id == movie.id }
    }
    
    func deleteMovies(_ moviesToDelete: [Movie]) throws {
        if shouldThrowError {
            throw errorToThrow
        }
        for movie in moviesToDelete {
            movies.removeAll { $0.id == movie.id }
        }
    }
    
    func deleteAllMovies() throws {
        if shouldThrowError {
            throw errorToThrow
        }
        movies.removeAll()
    }
    
    func getModelContext() -> ModelContext {
        // Mock에서는 실제 ModelContext가 필요 없으므로 에러 발생
        fatalError("Mock repository does not provide ModelContext")
    }
}
