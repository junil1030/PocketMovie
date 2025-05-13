//
//  PosterCardView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import SwiftUI
import Kingfisher

struct PosterCardView: View {
    let movie: Movie
    let isSelected: Bool
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let cardCornerRadius: CGFloat
    let cardBackgroundCornerRadius: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 여기서 전체 카드 사이즈를 적용
            ZStack {
                // 포스터 이미지
                if let posterURL = movie.posterURL, let url = URL(string: posterURL) {
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
                                .font(.headline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding()
                        )
                }
                
                VStack(alignment: .leading) {
                    Spacer()
                    
                    Text(movie.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .padding(.bottom, 4)
                    
                    HStack {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= Int(movie.rating) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                        
                        Spacer()
                        
                        Text(movie.releaseDate)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: cardWidth, height: cardHeight, alignment: .bottom)
            }
        }
        .clipShape(.rect(cornerRadius: cardCornerRadius))
        .padding(5)
        .background {
            RoundedRectangle(cornerRadius: cardBackgroundCornerRadius)
                .fill(.background)
        }
        .overlay(
            Group {
                if isSelected {
                    RoundedRectangle(cornerRadius: cardCornerRadius)
                        .stroke(Color.blue, lineWidth: 3)
                        .padding(5)
                }
            }
        )
        .opacity(isSelected ? 0.7 : 1.0)
    }
}

#Preview {
    //PosterCardView()
}
