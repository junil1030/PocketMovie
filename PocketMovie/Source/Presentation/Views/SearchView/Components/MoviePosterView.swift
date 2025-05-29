//
//  MoviePosterView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

import SwiftUI
import Kingfisher

struct MoviePosterView: View {
    let movie: TMDBMovie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
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
                    .frame(width: 100, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        Text("포스터 없음")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    )
            }
            
            // 영화 제목
            Text(movie.title)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 100, alignment: .leading)
        }
    }
}

#Preview {
    //MoviePosterView()
}
