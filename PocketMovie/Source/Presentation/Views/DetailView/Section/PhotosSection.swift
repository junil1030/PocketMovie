//
//  PhotosSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/30/25.
//

import SwiftUI
import Kingfisher

struct PhotosSection: View {
    let movieImages: [MovieImage]
    
    var body: some View {
        HorizontalScrollSection(title: "스틸샷") {
            ForEach(movieImages) { image in
                PhotoItemView(movieImage: image)
            }
        }
    }
}

struct PhotoItemView: View {
    let movieImage: MovieImage
    
    var body: some View {
        KFImage(URL(string: movieImage.fullImageURL))
            .resizable()
            .placeholder {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                    )
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: 200, height: 112)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(radius: 2)
    }
}

#Preview {
    PhotosSection(movieImages: [])
}
