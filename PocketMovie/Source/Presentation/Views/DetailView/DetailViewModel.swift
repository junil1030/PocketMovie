//
//  DetailViewModel.swift
//  PocketMovie
//
//  Created by 서준일 on 5/30/25.
//

import Foundation
import Combine

@MainActor
class DetailViewModel: ObservableObject {
    private var movieAPIService: MovieAPIService
    private var cancellables = Set<AnyCancellable>()
    
    let movieId: Int
    
    @Published var movieDetail: TMDBMovieDetail?
    @Published var movieImages: TMDBMovieImagesResponse?
    @Published var isLoading = false
    @Published var error: Error?
    
    init(movieId: Int) {
        self.movieId = movieId
        let container = DIContainer.shared
        self.movieAPIService = container.container.resolve(MovieAPIService.self)!
    }
    
    func loadMovieDetail() {
        isLoading = true
        error = nil
        
        let detailPublisher = movieAPIService.getMovieDetail(movieId: movieId)
        let imagesPublisher = movieAPIService.getMovieImages(movieId: movieId)
        
        Publishers.CombineLatest(detailPublisher, imagesPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] (movieDetail, movieImages) in
                self?.movieDetail = movieDetail
                self?.movieImages = movieImages
            }
            .store(in: &cancellables)
    }
}
