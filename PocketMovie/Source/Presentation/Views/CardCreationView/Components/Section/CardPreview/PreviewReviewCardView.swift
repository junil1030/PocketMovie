//
//  PreviewReviewCardView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import SwiftUI

struct PreviewReviewCardView: View {
    let movie: TMDBMovie
    let rating: Int
    let review: String
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    
    var body: some View {
        ZStack {
            // 배경
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8))
                .frame(width: cardWidth, height: cardHeight)
            
            // 리뷰 텍스트
            VStack(spacing: 4) {
                Text(movie.title)
                    .font(.system(size: 15))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Divider()
                    .background(Color.white)
                    .frame(width: cardWidth * 0.8)
                
                Text(review.isEmpty ? "리뷰를 입력해주세요" : review)
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(5)
                    .padding(.horizontal, 4)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .font(.system(size: 13))
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.bottom, 4)
            }
            .padding(6)
            .frame(width: cardWidth, height: cardHeight)
            .rotation3DEffect(
                .degrees(180),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(radius: 2)
    }
}


#Preview {
    //PreviewReviewCardView()
}
