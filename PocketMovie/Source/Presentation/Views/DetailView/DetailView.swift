//
//  DetailView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/30/25.
//

import SwiftUI

struct DetailView: View {
    let movie: TMDBMovie
    @StateObject private var viewModel: DetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(movie: TMDBMovie) {
        self.movie = movie
        _viewModel = StateObject(wrappedValue: DetailViewModel(movieId: movie.id))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    if let movieDetail = viewModel.movieDetail {
                        // 영화 정보 섹션
                        MovieInfoSection(movie: movie)
                        
                        // 줄거리 섹션
                        MovieOverviewSection(movie: movie)
                            .padding(.top, 16)
                        
                        // 출연진 섹션
                        if let cast = movieDetail.credits?.cast, !cast.isEmpty {
                            CastSection(cast: cast)
                                .padding(.top, 24)
                        }
                        
                        // 스틸컷 섹션
                        if let movieImages = viewModel.movieImages, !movieImages.backdrops.isEmpty {
                            PhotosSection(movieImages: Array(movieImages.backdrops.prefix(10)))
                                .padding(.top, 24)
                        }
                        
                        // 예고편 및 영상 섹션
                        if let videos = movieDetail.videos?.results, !videos.isEmpty {
                            VideosSection(videos: videos.filter { $0.site == "YouTube" })
                                .padding(.top, 24)
                        }
                        
                        // 비슷한 영화 섹션
                        if let similarMovies = movieDetail.similar?.results, !similarMovies.isEmpty {
                            SimilarMoviesSection(movies: similarMovies)
                                .padding(.top, 24)
                        }
                        
                        // 추천 영화 섹션
                        if let recommendedMovies = movieDetail.recommendations?.results, !recommendedMovies.isEmpty {
                            RecommendedMoviesSection(movies: recommendedMovies)
                                .padding(.top, 24)
                        }
                    } else if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                    } else if let error = viewModel.error {
                        Text("오류 발생: \(error.localizedDescription)")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear() {
            viewModel.loadMovieDetail()
        }
    }
}

#Preview {
    //DetailView()
}
