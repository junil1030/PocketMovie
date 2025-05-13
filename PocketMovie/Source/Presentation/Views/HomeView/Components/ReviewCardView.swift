//
//  ReviewCardView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import SwiftUI

struct ReviewCardView: View {
    let movie: Movie
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let cardCornerRadius: CGFloat
    let cardBackgroundCornerRadius: CGFloat
    
    var body: some View {
        ZStack {
            // 배경
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(Color.black.opacity(0.8))
                .frame(width: cardWidth, height: cardHeight)
            
            // 리뷰 텍스트
            VStack(spacing: 20) {
                Text(movie.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Divider()
                    .background(Color.white)
                
                Text("\"" + movie.review + "\"")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                HStack {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= Int(movie.rating) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.bottom)
            }
            .padding()
            .frame(width: cardWidth, height: cardHeight)
            .rotation3DEffect(
                .degrees(180),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .clipShape(.rect(cornerRadius: cardCornerRadius))
        .padding(5)
        .background {
            RoundedRectangle(cornerRadius: cardBackgroundCornerRadius)
                .fill(.background)
        }
    }
}

#Preview {
    //ReviewCardView()
}
