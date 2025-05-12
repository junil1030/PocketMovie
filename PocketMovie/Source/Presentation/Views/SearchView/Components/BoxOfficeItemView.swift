//
//  BoxOfficeitemView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

import SwiftUI
import Kingfisher

struct BoxOfficeItemView: View {
    let rank: Int
    let title: String
    let posterURL: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topLeading) {
                // 포스터 이미지 또는 기본 이미지
                if let posterURL = posterURL, let url = URL(string: posterURL) {
                    KFImage(url)
                        .resizable()
                        .placeholder {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(ProgressView())
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            Text(title)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(4)
                        )
                }
                
                Text("\(rank)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color.blue)
                            .shadow(radius: 2)
                    )
                    .padding(4)
            }
            
            Text(title)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 120, alignment: .leading)
        }
    }
}

#Preview {
    BoxOfficeItemView(rank: 1, title: "테스트", posterURL: nil)
}
