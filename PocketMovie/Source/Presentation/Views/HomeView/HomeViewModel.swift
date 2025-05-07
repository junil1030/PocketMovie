//
//  HomeViewModel.swift
//  PocketMovie
//
//  Created by 서준일 on 5/3/25.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class MainViewModel: ObservableObject {
    private let repository: MovieRepository
    
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    init(repository: MovieRepository) {
        self.repository = repository
        fetchMovies()
    }
    
    func fetchMovies() {
        isLoading = true
        error = nil
        
        movies = repository.getAllMovies()
        
        isLoading = false
    }
    
    func deleteMovie(_ movie: Movie) {
        isLoading = true
        error = nil
        
        do {
            try repository.deleteMovie(movie)
            movies = repository.getAllMovies()
        } catch {
            self.error = error
            print("영화 삭제 오류: \(error)")
        }
        
        isLoading = false
    }
    
    func deleteMovies(_ movies: [Movie]) {
        isLoading = true
        error = nil
        
        do {
            try repository.deleteMovies(movies)
            self.movies = repository.getAllMovies()
        } catch {
            self.error = error
            print("영화 일괄 삭제 오류: \(error)")
        }
        
        isLoading = false
    }
    
    func getModelContext() -> ModelContext {
        return repository.getModelContext()
    }
}
