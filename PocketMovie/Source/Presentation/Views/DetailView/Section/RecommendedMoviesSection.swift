//
//  RecommendedMoviesSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/30/25.
//

import SwiftUI

struct RecommendedMoviesSection: View {
    let movies: [TMDBMovie]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("추천 영화")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(movies) { movie in
                        NavigationLink(destination: DetailView(movie: movie)) {
                            MoviePosterItemView(movie: movie)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 24) // 마지막 섹션이므로 하단 패딩 추가
    }
}

#Preview {
    RecommendedMoviesSection(movies: [
        TMDBMovie(
            id: 1,
            title: "테스트 영화",
            originalTitle: "Test Movie",
            posterPath: "/test.jpg",
            backdropPath: nil,
            releaseDate: "2024-01-01",
            overview: "테스트용 영화입니다.",
            voteAverage: 7.5,
            voteCount: 100
        )
    ])
}
