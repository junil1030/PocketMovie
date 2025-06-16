//
//  MovieTestFactory.swift
//  PocketMovie
//
//  Created by 서준일 on 5/10/25.
//

import Foundation
@testable import PocketMovie

@MainActor
struct MovieTestFactory {
    static func createMockMovie(
        title: String = "테스트 영화",
        releaseDate: String = "2025-05-10",
        posterURL: String? = "http://file.koreafilm.or.kr/thm/02/99/18/94/tn_DPF031047.jpg",
        rating: Double = 4.5,
        review: String = "테스트 리뷰",
        watchedDate: Date = Date(),
        genres: [String] = ["액션"]
    ) -> Movie {
        return Movie(
            title: title,
            releaseDate: releaseDate,
            rating: rating,
            review: review,
            watchedDate: watchedDate,
            genres: genres
        )
    }
    
    static func createMockMovies() -> [Movie] {
        return [
            createMockMovie(
                title: "인터스텔라",
                releaseDate: "2014-11-06",
                rating: 5.0,
                review: "감동적인 우주 영화",
                genres: ["SF", "액션"]
            ),
            createMockMovie(
                title: "어벤져스: 엔드게임",
                releaseDate: "2019-04-24",
                rating: 4.5,
                review: "완벽한 마블 영화",
                genres: ["액션"]
            ),
            createMockMovie(
                title: "듄",
                releaseDate: "2021-10-20",
                rating: 4.0,
                review: "시각적으로 놀라운 영화",
                genres: ["액션", "스릴러", "코미디"]
            )
        ]
    }
}
