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
class HomeViewModel: ObservableObject {
    private let movieUseCase: MovieUseCase
    
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    init(movieUseCase: MovieUseCase) {
        self.movieUseCase = movieUseCase
        fetchMovies()
    }
    
    func fetchMovies() {
        isLoading = true
        error = nil
        
        movies = movieUseCase.getAllMovies()
        
        isLoading = false
    }
    
    func deleteMovie(_ movie: Movie) {
        isLoading = true
        error = nil
        
        do {
            try movieUseCase.deleteMovie(movie)
            movies = movieUseCase.getAllMovies()
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
            try movieUseCase.deleteMovies(movies)
            self.movies = movieUseCase.getAllMovies()
        } catch {
            self.error = error
            print("영화 일괄 삭제 오류: \(error)")
        }
        
        isLoading = false
    }
    
    func getModelContext() -> ModelContext {
        return movieUseCase.getModelContext()
    }
}
