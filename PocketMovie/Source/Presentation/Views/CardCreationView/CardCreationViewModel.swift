//
//  CardCreationViewModel.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

import SwiftUI
import Combine

@MainActor
class CardCreationViewModel: ObservableObject {
    let movie: KMDBMovie
    private let movieUseCase: MovieUseCase
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showErrorAlert = false
    @Published var showSavedAlert = false
    
    init(movie: KMDBMovie, movieUseCase: MovieUseCase) {
        self.movie = movie
        self.movieUseCase = movieUseCase
    }
    
    func saveCard(rating: Double, review: String) {
        isLoading = true
        
        do {
            let newMovie = Movie(
                title: movie.cleanTitle,
                releaseDate: movie.repRlsDate,
                posterURL: movie.firstPosterURL,
                rating: rating,
                review: review,
                watchedDate: Date()
            )
            
            try movieUseCase.saveMovie(newMovie)
            isLoading = false
            showSavedAlert = true
        } catch {
            isLoading = false
            errorMessage = "영화 카드 저장 실패: \(error.localizedDescription)"
            showErrorAlert = true
            print("영화 카드 저장 오류: \(error)")
        }
    }
}
