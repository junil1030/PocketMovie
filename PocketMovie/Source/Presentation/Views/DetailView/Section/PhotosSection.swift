//
//  PhotoSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/30/25.
//

import SwiftUI
import Kingfisher

struct PhotoSection: View {
    let backdropPaths: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("스틸샷")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(backdropPaths, id: \.self) { backdropPath in
                        PhotoItemView(backdropPath: backdropPath)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct PhotoItemView: View {
    let backdropPath: String
    
    private var backdropURL: String {
        "https://image.tmdb.org/t/p/w500\(backdropPath)"
    }
    
    var body: some View {
        KFImage(URL(string: backdropURL))
            .resizable()
            .placeholder {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                    )
            }
            .aspectRatio(16/9, contentMode: .fill)
            .frame(width: 200, height: 112)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(radius: 2)
    }
}

#Preview {
    PhotosSection(backdropPaths: ["/mroWh717g0Ah2c0rrPGW6f3EWMM.jpg"])
}
