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
    @Published var isLoading = false
    @Published var error: Error?
    
    init(repository: MovieRepository) {
        self.repository = repository
    }
    
    func deleteMovie(_ movie: Movie) async {
        isLoading = true
        error = nil
        
        do {
            try await repository.deleteMovie(movie)
        } catch {
            self.error = error
            print("영화 삭제 오류: \(error)")
        }
        
        isLoading = false
    }
    
    func deleteMovies(_ movies: [Movie]) async {
        isLoading = true
        error = nil
        
        do {
            try await repository.deleteMovies(movies)
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
