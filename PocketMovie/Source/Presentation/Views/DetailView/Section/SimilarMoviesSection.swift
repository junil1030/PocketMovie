//
//  SimilarMoviesSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/30/25.
//

import SwiftUI

struct SimilarMoviesSection: View {
    let movies: [TMDBMovie]
    
    var body: some View {
        HorizontalScrollSection(title: "비슷한 영화") {
            ForEach(movies) { movie in
                MoviePosterItemView(movie: movie)
            }
        }
    }
}

#Preview {
    SimilarMoviesSection(movies: [
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
