//
//  BoxOfficeSectionView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

import SwiftUI

struct BoxOfficeView: View {
    let title: String
    let items: [String]
    let isLoading: Bool
    let error: Error?
    let getPosterURL: (String) -> String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if let error = error {
                Text("데이터 로드 오류: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            } else if items.isEmpty {
                Text("데이터가 없습니다.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(zip(items.indices, items)), id: \.0) { index, title in
                            BoxOfficeItemView(
                                rank: index + 1,
                                title: title,
                                posterURL: getPosterURL(title)
                            )
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    //BoxOfficeView()
}
