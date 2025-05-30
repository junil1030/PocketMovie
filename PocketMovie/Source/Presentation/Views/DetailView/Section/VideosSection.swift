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
        VStack(alignment: .leading, spacing: 12) {
            Text("예고편 및 영상")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(videos) { video in
                        VideoItemView(video: video)
                    }
                }
                .padding(.horizontal)
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
        .alert("유튜브 영상", isPresented: $showingVideoAlert) {
            Button("YouTube에서 보기") {
                if let url = URL(string: video.youtubeURL ?? "") {
                    UIApplication.shared.open(url)
                }
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("이 영상을 YouTube에서 보시겠습니까?\n\(video.name)")
        }
    }
}

#Preview {
    VideosSection(videos: [
        Video(id: "1", key: "dQw4w9WgXcQ", name: "미션 임파서블 예고편", site: "YouTube", type: "Trailer", official: true)
    ])
}
