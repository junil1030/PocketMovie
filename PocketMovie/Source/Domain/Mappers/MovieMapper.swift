//
//  MovieMapper.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import Foundation

struct MovieMapper {
    
    // KMDB API 응답에서 Movie 객체로 변환
    static func mapFromKMDB(_ kmdbMovie: KMDBMovie, isBoxOffice: Bool = false, rank: Int? = nil, boxOfficeType: String? = nil) -> Movie {
        return Movie(
            title: kmdbMovie.cleanTitle,
            releaseDate: kmdbMovie.repRlsDate,
            posterURL: kmdbMovie.firstPosterURL,
            rank: rank,
            boxOfficeType: boxOfficeType,
            isBoxOffice: isBoxOffice
        )
    }
    
    // 일간 박스오피스 데이터에서 Movie 객체로 변환
    static func mapFromDailyBoxOffice(_ boxOffice: DailyBoxOffice) -> Movie {
        return Movie(
            title: boxOffice.movieNm,
            releaseDate: boxOffice.openDt,
            rank: Int(boxOffice.rank) ?? 0,
            boxOfficeType: "daily",
            isBoxOffice: true
        )
    }
    
    // 주간 박스오피스 데이터에서 Movie 객체로 변환
    static func mapFromWeeklyBoxOffice(_ boxOffice: WeeklyBoxOffice) -> Movie {
        return Movie(
            title: boxOffice.movieNm,
            releaseDate: boxOffice.openDt,
            rank: Int(boxOffice.rank) ?? 0,
            boxOfficeType: "weekly",
            isBoxOffice: true
        )
    }
    
    // 포스터 URL 연결 (박스오피스 영화에 포스터 URL 추가)
    static func updateMovieWithPosterURL(_ movie: Movie, posterURL: String?) -> Movie {
        movie.posterURL = posterURL
        return movie
    }
    
    // 저장된 Movie와 API에서 받은 영화 정보를 합치는 메서드
    static func updateMovieDetails(_ savedMovie: Movie, with kmdbMovie: KMDBMovie) -> Movie {
        savedMovie.title = kmdbMovie.cleanTitle
        savedMovie.releaseDate = kmdbMovie.repRlsDate
        savedMovie.posterURL = kmdbMovie.firstPosterURL
        
        return savedMovie
    }
    
    // 사용자 리뷰 정보 추가
    static func updateUserReview(_ movie: Movie, rating: Double, review: String) -> Movie {
        movie.rating = rating
        movie.review = review
        movie.watchedDate = Date()
        return movie
    }
}
