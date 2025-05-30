//
//  MoviePosterItemView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/30/25.
//

import SwiftUI
import Kingfisher

struct MoviePosterItemView: View {
    let movie: TMDBMovie
    
    var body: some View {
        NavigationLink(destination: DetailView(movie: movie)) {
            VStack(alignment: .leading, spacing: 8) {
                // 포스터 이미지
                if let posterURL = movie.fullPosterURL {
                    KFImage(URL(string: posterURL))
                        .resizable()
                        .placeholder {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    ProgressView()
                                )
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(radius: 2)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            Text("포스터 없음")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    // 영화 제목
                    Text(movie.title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.black)
                        .lineLimit(2)
                        .frame(width: 120, alignment: .leading)
                    
                    // 개봉 날짜
                    if !movie.releaseDate.isEmpty {
                        Text(String(movie.releaseDate))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    // 평점
                    if movie.voteAverage > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", movie.voteAverage))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    MoviePosterItemView(movie: TMDBMovie(
        id: 87359,
        title: "미션 임파서블: 파이널 레코닝",
        originalTitle: "미션 임파서블: 파이널 레코닝",
        posterPath: "/jPrAjeK4APOhPSrHrLqSmXF2Z8a.jpg",
        backdropPath: "/mroWh717g0Ah2c0rrPGW6f3EWMM.jpg",
        releaseDate: "2025-05-17",
        overview: "디지털상의 모든 정보를 통제할 수 있는...",
        voteAverage: 7.1,
        voteCount: 413
    ))
}
