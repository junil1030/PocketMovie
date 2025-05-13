//
//  MovieInfoSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import SwiftUI

struct MovieInfoSection: View {
    let movie: KMDBMovie
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // 영화 정보
            VStack(alignment: .leading, spacing: 12) {
                Text(movie.cleanTitle)
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                if !movie.repRlsDate.isEmpty {
                    Text("개봉일: \(movie.repRlsDate)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
    }
}

#Preview {
    //MovieInfoSection()
}
