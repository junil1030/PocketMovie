//
//  PreviewPosterCardView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import SwiftUI
import Kingfisher

struct PreviewPosterCardView: View {
    let movie: TMDBMovie
    let rating: Int
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 포스터 이미지
            if let posterURL = movie.fullPosterURL, let url = URL(string: posterURL) {
                KFImage(url)
                    .resizable()
                    .placeholder {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                ProgressView()
                            )
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cardWidth, height: cardHeight)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: cardWidth, height: cardHeight)
                    .overlay(
                        Text(movie.title)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .padding(4)
                    )
            }
            
            // 평점 그라데이션 마스크
            VStack(alignment: .leading, spacing: 2) {
                Spacer()
                
                Text(movie.title)
                    .font(.system(size: 13).bold())
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 10) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .font(.system(size: 8))
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    if !movie.releaseDate.isEmpty {
                        Text(movie.releaseDate)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .padding(5)
            .frame(width: cardWidth)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(radius: 2)
    }
}

#Preview {
    //PreviewPosterCardView()
}
