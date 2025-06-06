//
//  VideosSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/30/25.
//

import SwiftUI
import Kingfisher

struct VideosSection: View {
    let videos: [Video]
    
    var body: some View {
        HorizontalScrollSection(title: "예고편 및 영상") {
            ForEach(videos) { video in
                VideoItemView(video: video)
            }
        }
    }
}

struct VideoItemView: View {
    let video: Video
    @State private var showingVideoAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 유튜브 썸네일
            Button {
                showingVideoAlert = true
            } label: {
                ZStack {
                    if let thumbnailURL = video.youtubeThumbnailURL {
                        KFImage(URL(string: thumbnailURL))
                            .resizable()
                            .placeholder {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(
                                        ProgressView()
                                    )
                            }
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(width: 160, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 160, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // 재생 버튼
                    Image(systemName: "play.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .shadow(radius: 4)
                }
            }
            
            // 비디오 제목
            Text(video.name)
                .font(.caption)
                .lineLimit(2)
                .frame(width: 160, alignment: .leading)
        }
        .sheet(isPresented: $showingVideoAlert) {
            YouTubePlayerSheet(video: video)
        }
    }
}

#Preview {
    VideosSection(videos: [
        Video(id: "1", key: "dQw4w9WgXcQ", name: "미션 임파서블 예고편", site: "YouTube", type: "Trailer", official: true)
    ])
}
