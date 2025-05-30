//
//  MovieInfoSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import SwiftUI
import Kingfisher

struct MovieInfoSection: View {
    let movie: TMDBMovie
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let backdropURL = movie.backdropURL {
                KFImage(URL(string: backdropURL))
                    .resizable()
                    .placeholder {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                ProgressView()
                            )
                    }
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                            startPoint: .top
                            , endPoint: .bottom
                        )
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        Text("배경 이미지 없음")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    )
            }
            
            HStack(alignment: .bottom, spacing: 12) {
                if let posterURL = movie.fullPosterURL {
                    KFImage(URL(string: posterURL))
                        .resizable()
                        .placeholder {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    ProgressView()
                                        .tint(.white)
                                )
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(radius: 4)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            Text("포스터\n없음")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        )

                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(movie.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .shadow(radius: 2)
                    
                    if !movie.releaseDate.isEmpty {
                        Text("개봉일: \(movie.releaseDate)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(radius: 2)
                    }
                    
                    // 평점 정보 추가
                    if movie.voteAverage > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text(String(format: "%.1f", movie.voteAverage))
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .shadow(radius: 2)
                    }
                }
                
                Spacer()
            }
            .padding(16)
        }
    }
}

#Preview {
    MovieInfoSection(
        movie: TMDBMovie(
        id: 87359,
        title: "미션 임파서블: 파이널 레코닝",
        originalTitle: "미션 임파서블: 파이널 레코닝",
        posterPath: "/jPrAjeK4APOhPSrHrLqSmXF2Z8a.jpg",
        backdropPath: "/mroWh717g0Ah2c0rrPGW6f3EWMM.jpg",
        releaseDate: "2025-05-17",
        overview: "디지털상의 모든 정보를 통제할 수 있는 사상 초유의 무기로 인해 전 세계 국가와 조직의 기능이 마비되고, 인류 전체가 위협받는 절체절명의 위기가 찾아온다. 이를 막을 수 있는 건 오직 존재 자체가 기밀인 에단 헌트와 그가 소속된 IMF뿐이다. 무기를 무력화하는 데 반드시 필요한 키를 손에 쥔 에단 헌트. 오랜 동료 루터와 벤지, 그리고 새로운 팀원이 된 그레이스, 파리, 드가와 함께 지금껏 경험했던 그 어떤 상대보다도 강력한 적에 맞서 모두의 운명을 건 불가능한 미션에 뛰어든다.",
        voteAverage: 7.1,
        voteCount: 413)
    )
}
