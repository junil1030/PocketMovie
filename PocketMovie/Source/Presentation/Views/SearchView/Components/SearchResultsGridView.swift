//
//  SearchResultsGridView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

import SwiftUI

struct SearchResultsGridView: View {
    let searchResults: [TMDBMovie]
    let isLoading: Bool
    let error: Error?
    
    // 그리드 레이아웃 설정
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if let error = error {
                Text("오류 발생: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            } else if searchResults.isEmpty {
                Text("검색 결과가 없습니다.")
                    .foregroundColor(Color("AppTextColor").opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Text("검색 결과: \(searchResults.count)개")
                    .font(.headline)
                    .foregroundColor(Color("AppTextColor"))
                    .padding(.bottom, 8)
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(searchResults) { movie in
                        MoviePosterItemView(movie: movie)
                    }
                }
            }
        }
    }
}

#Preview {
    //SearchResultsGridView()
}
