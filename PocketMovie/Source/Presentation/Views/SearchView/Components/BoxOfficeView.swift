//
//  BoxOfficeSectionView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

import SwiftUI

struct BoxOfficeView: View {
    let title: String
    let movies: [TMDBMovie]
    let isLoading: Bool
    let error: Error?
    let isDailyBoxOffice: Bool // 일간/주간 구분용
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isLoading {
                VStack {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                    
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            } else if let error = error {
                VStack {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                    
                    Text("데이터 로드 오류: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                }
            } else if movies.isEmpty {
                VStack {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                    
                    Text("데이터가 없습니다.")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                }
            } else {
                HorizontalScrollSection(title: title) {
                    ForEach(Array(movies.enumerated()), id: \.element.id) { index, movie in
                        ZStack(alignment: .topLeading) {
                            MoviePosterItemView(movie: movie)
                            
                            // 순위 표시
                            Text("\(index + 1)")
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
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    //BoxOfficeView()
}
